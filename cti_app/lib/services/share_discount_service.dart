import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '/models/discounts.dart';
import '/models/product.dart';

class ShareDiscountService {
  static Future<void> shareDiscount({
    required BuildContext context,
    required Discount discount,
    required Product product,
  }) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String shareText = _generateShareText(discount, product) as String;
    final String subject = 'Découvrez cette promotion exclusive !';

    await Share.share(
      shareText,
      subject: subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  static Future<void> shareOnWhatsApp({
    required Discount discount,
    required Product product,
  }) async {
    final String text = _generateShareText(discount, product) as String;
    final String url = 'https://wa.me/?text=${Uri.encodeComponent(text)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      const SnackBar(
        content: Text('Impossible d\'ouvrir WhatsApp'),
        duration: Duration(seconds: 2),
      );
      throw 'Impossible d\'ouvrir WhatsApp';
    }
  }
  //vvvv

  static Future<void> shareOnFacebook({
    required Discount discount,
    required Product product,
  }) async {
    final String text = _generateShareText(discount, product) as String;
    final String url = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(text)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Impossible d\'ouvrir Facebook';
    }
  }

  static Future<void> shareOnInstagram({
    required Discount discount,
    required Product product,
    required String imagePath,
  }) async {
    try {
      // 1. Vérifier si l'image existe
      final file = XFile(imagePath);
      final exists = await File(file.path).exists();
      if (!exists) {
        throw Exception("L'image n'existe pas");
      }

      // 2. Préparer le texte avec des hashtags
      final categoryName = product.category.name;
      final categoryHashtag = categoryName.isNotEmpty 
          ? '#${categoryName.replaceAll(' ', '')}' 
          : '';
      final text = [
        '🔥 Promotion Exclusive 🔥',
        '${product.name} - ${discount.promotionPrice.toStringAsFixed(2)} MAD',
        'Économisez ${((discount.normalPrice - discount.promotionPrice) / discount.normalPrice * 100).round()}%',
        categoryHashtag,
        '#Promo #Shopping'
      ].join('\n');

      // 3. Partager avec l'option Instagram si disponible
      await Share.shareXFiles(
        [file],
        text: text,
        sharePositionOrigin: Rect.zero,
      );

    } catch (e) {
      // Fallback: Partage générique si Instagram échoue
      await Share.share(
        _generateShareText(discount, product) as String,
        subject: 'Promotion ${product.name}',
      );
    }
  }

  static Future<void> shareViaEmail({
    required Discount discount,
    required Product product,
    required String recipientEmail,
  }) async {
    final String subject = 'Promotion exclusive: ${product.name}';
    final String body = _generateShareText(discount, product) as String;
    final String url = 'mailto:$recipientEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Aucune application email configurée';
    }
  }

  static Future<void> shareViaSMS({
    required Discount discount,
    required Product product,
    required String phoneNumber,
  }) async {
    final String text = _generateShareText(discount, product) as String;
    final String url = 'sms:$phoneNumber?body=${Uri.encodeComponent(text)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Impossible d\'envoyer un SMS';
    }
  }

  static Future<String> _generateShareText(Discount discount, Product product) async {
    final discountPercentage = ((discount.normalPrice - discount.promotionPrice) / 
                            discount.normalPrice * 100).round();

    return '''
🔥 Promotion Exclusive 🔥

🎁 Produit: ${product.name}
🏷️ Catégorie: ${product.category.name}
💰 Prix normal: ${discount.normalPrice.toStringAsFixed(2)} MAD
💲 Prix promo: ${discount.promotionPrice.toStringAsFixed(2)} MAD
🤑 Économisez: $discountPercentage%

📅 Validité: ${discount.validity}

📝 Description: ${discount.description}

Ne manquez pas cette offre exceptionnelle !
#Promotion #${product.category.name} #Economisez
''';
  }

  static Future<void> showShareOptions({
    required BuildContext context,
    required Discount discount,
    required Product product,
    String? imagePath,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Partager la promotion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey[300]),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Partager via...'),
              onTap: () {
                Navigator.pop(context);
                shareDiscount(context: context, discount: discount, product: product);
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/whatsapp.png', width: 24, height: 24),
              title: const Text('WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                await shareOnWhatsApp(discount: discount, product: product);
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/facebook.png', width: 24, height: 24),
              title: const Text('Facebook'),
              onTap: () async {
                Navigator.pop(context);
                await shareOnFacebook(discount: discount, product: product);
              },
            ),
            if (imagePath != null)
              ListTile(
                leading: Image.asset('assets/icons/instagram.png', width: 24, height: 24),
                title: const Text('Instagram'),
                onTap: () async {
                  Navigator.pop(context);
                  await shareOnInstagram(
                    discount: discount,
                    product: product,
                    imagePath: imagePath,
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('Email'),
              onTap: () async {
                Navigator.pop(context);
                // Implémentez une boîte de dialogue pour saisir l'email
                _showEmailDialog(context, discount, product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sms, color: Colors.green),
              title: const Text('SMS'),
              onTap: () async {
                Navigator.pop(context);
                // Implémentez une boîte de dialogue pour saisir le numéro
                _showSmsDialog(context, discount, product);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showEmailDialog(BuildContext context, Discount discount, Product product) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer par email'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Adresse email',
            hintText: 'entrez@email.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(context);
                await shareViaEmail(
                  discount: discount,
                  product: product,
                  recipientEmail: emailController.text,
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  static void _showSmsDialog(BuildContext context, Discount discount, Product product) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer par SMS'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Numéro de téléphone',
            hintText: '0612345678',
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (phoneController.text.isNotEmpty) {
                Navigator.pop(context);
                await shareViaSMS(
                  discount: discount,
                  product: product,
                  phoneNumber: phoneController.text,
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}