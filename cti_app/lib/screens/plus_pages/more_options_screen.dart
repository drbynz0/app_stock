
import 'package:cti_app/controller/external_orders_controller.dart';
import 'package:cti_app/controller/internal_orders_controller.dart';
import 'package:cti_app/screens/categorie/categorie_management_screen.dart';
import 'package:cti_app/screens/employes/sellers_management_screen.dart';
import 'package:cti_app/services/profile_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controller/product_controller.dart';
import '/screens/delivery_pages/delivery_management.dart';
import '../discounts_pages/discounts_management.dart';
import '../factures_pages/factures_management_screen.dart';
import '../fourns_pages/suppliers_management_screen.dart';
import '../stats/stats.dart';
import '/models/internal_order.dart';
import '/models/external_order.dart';
import '/models/product.dart';

class MoreOptionsScreen extends StatefulWidget {
  const MoreOptionsScreen({super.key});

  @override
  MoreOptionsScreenState createState() => MoreOptionsScreenState();
}

class MoreOptionsScreenState extends State<MoreOptionsScreen> {
  Map<String, dynamic> userData = {};
  List<Product> products = [];
  List<InternalOrder> internalOrders = [];
  List<ExternalOrder> externalOrders = [];
  List<Map<String, dynamic>> options = [];
  Map<String, dynamic>? _profile= {};

  @override
  void initState() {
    super.initState();
    _loadOption();
    // Initialisation ou chargement de données si nécessaire
  }
  Future<void> _loadOption() async {
    final updatedProfile = Provider.of<ProfileService>(context, listen: false).userProfile;

    final fetchInternalOrders = await InternalOrdersController.fetchOrders();
    final fetchExternalOrders = await ExternalOrdersController.fetchOrders();
    final fetchedProducts = await ProductController.fetchProducts();
    setState(() {
      _profile = updatedProfile;
      internalOrders = fetchInternalOrders;
      externalOrders = fetchExternalOrders;
      products = fetchedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {

    options = [
      {'icon': Icons.percent, 'label': 'Discounts'},
      {'icon': Icons.local_shipping, 'label': 'Fournisseurs'},
      {'icon': Icons.bar_chart, 'label': 'Stats'},
      {'icon': Icons.receipt_long, 'label': 'Factures'},
      {'icon': Icons.assignment, 'label': 'Bon à délivrer'},
      {'label': 'Catégories',  'icon': Icons.category},
    ];

    return Scaffold(
      body: _buildBody(options, context),
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> options, BuildContext context) {
    if(_profile!['is_staff'] == true) {
      options.add({'label': 'Employés', 'icon': Icons.people});
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          return _buildListTile(options[index], context);
        },
      ),
    );
  }

  Widget _buildListTile(Map<String, dynamic> option, BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Coins arrondis pour un effet moderne
      ),
      elevation: 5, // Ombre pour un effet de profondeur
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Espacement entre les cartes
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Espacement interne
        leading: CircleAvatar(
          radius: 24, // Plus grand pour un meilleur effet visuel
          backgroundColor: Colors.blue.shade50,
          child: Icon(option['icon'], color: Colors.blue.shade900, size: 28), // Icône avec plus de visibilité
        ),
        title: Text(
          option['label'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: theme.titleColor, // Texte en bleu foncé pour mieux ressortir
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: theme.iconColor, // Changer la couleur de l'icône de droite
        ),
        onTap: () {
          _handleOptionTap(option['label'], context);
        },
      ),
    );
  }

  void _handleOptionTap(String label, BuildContext context) {
    if (label == 'Discounts') {
      // Naviguer vers la page DiscountsManagementScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DiscountsManagementScreen(),
        ),
      );
    } else if (label == 'Factures') {
      // Afficher un SnackBar pour la page Factures
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacturesManagementScreen(),
        ),
      );
    } else if (label == 'Fournisseurs') {
      // Naviguer vers la page SuppliersManagementScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SuppliersManagementScreen(),
        ),
      );
    } else if (label == 'Stats') {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => StatsPage(
            internalOrders: internalOrders,
            externalOrders: externalOrders,
            allProducts: products,
          ),
        ),
      );
    } else if (label == 'Bon à délivrer') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DeliveryNotesScreen(),
        ),
      );

      } else if (label == 'Catégories') {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CategorieScreen(),
        ),

        );
     } else if (label == 'Employés') {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EmployeScreen(),
        ),

        );
     } else {
      // Afficher un SnackBar pour les autres options
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label cliqué')),
      );
    }
  }
}