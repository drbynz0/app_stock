// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cti_app/services/activity_service.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '/models/internal_order.dart';
import 'delete_order_dialog.dart';
import 'edit_internal_order_screen.dart';
import 'add_internal_order_screen.dart';
import 'details_internal_order.dart';
import '../../services/internal_orderlist_pdfservice.dart';

class InternalOrdersScreen extends StatefulWidget {
  const InternalOrdersScreen({super.key});

  @override
  InternalOrdersScreenState createState() => InternalOrdersScreenState();
}

class InternalOrdersScreenState extends State<InternalOrdersScreen> {
  List<InternalOrder> _orders = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  TypeOrder? _selectedOrderType;
  
  Map<String, dynamic>? myPrivileges = {};
  Map<String, dynamic>? userData = {};

  @override
  void initState() {
    super.initState();
    _refreshOption();
  }

  Future<void> _refreshOption() async {
    final appData = Provider.of<AppData>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        appData.refreshDataService(context);
      }
    });

    if (appData.internalOrders.isEmpty) {
      await appData.fetchInternalOrders();
    }

    myPrivileges = appData.myPrivileges;
    userData = appData.userData;

    if (mounted) {
      setState(() {
        _orders = appData.internalOrders;
      });
    }
  }

  List<InternalOrder> get _filteredOrders {
    return _orders.where((order) {
      final matchesSearch = order.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.orderNum.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesType = _selectedOrderType == null || order.typeOrder == _selectedOrderType;
      
      return matchesSearch && matchesType;
    }).toList();
  }

  List<InternalOrder> get paginatedOrders {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    endIndex = endIndex > _filteredOrders.length ? _filteredOrders.length : endIndex;
    return _filteredOrders.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final appData = Provider.of<AppData>(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.searchBar,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor,
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher des commandes...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.searchBar,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor,
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<TypeOrder>(
                                value: _selectedOrderType,
                                hint: const Text('Tous les types'),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Tous les types'),
                                  ),
                                  ...TypeOrder.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type == TypeOrder.online 
                                            ? 'En ligne' 
                                            : 'En magasin'),
                                    );
                                  }),
                                ],
                                onChanged: (TypeOrder? newValue) {
                                  setState(() {
                                    _selectedOrderType = newValue;
                                    _currentPage = 1;
                                    if (newValue == null) {
                                      _refreshOption();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.searchBar,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.calendar_today, color: theme.iconColor),
                            onPressed: () async {
                              final DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return theme.themeData.brightness == Brightness.dark
                                    ? Theme(
                                        data: ThemeData.dark(),
                                        child: child!,
                                      )
                                    : Theme(
                                        data: ThemeData.light(),
                                        child: child!,
                                      );
                                },
                              );
                              if (selectedDate != null) {
                                final filteredOrders = _orders
                                    .where((order) {
                                      return order.date.year == selectedDate.year &&
                                          order.date.month == selectedDate.month &&
                                          order.date.day == selectedDate.day;
                                    }).toList();

                                if (filteredOrders.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Aucune commande trouvée pour le ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    _orders = filteredOrders;
                                    _selectedOrderType = null;
                                    _currentPage = 1;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: paginatedOrders.length,
                  itemBuilder: (context, index) {
                    final order = paginatedOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredOrders.length} commandes',
                      style: TextStyle(color: theme.secondaryTextColor),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text(
                          'Page $_currentPage/${(_filteredOrders.length / _itemsPerPage).ceil()}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _currentPage < (_filteredOrders.length / _itemsPerPage).ceil()
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 120,
            child: IconButton(
              onPressed: () async {
                try {
                  if (Platform.isAndroid) {
                    final status = await Permission.storage.status;
                    if (!status.isGranted) {
                      await Permission.storage.request();
                    }
                  }

                  final pdfBytes = await InternalOrderPdfService.generateInternalOrdersPdf(_orders);

                  final directory = await getExternalStorageDirectory();
                  if (directory == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Impossible d\'accéder au stockage'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  final folder = Directory('${directory.path}/Pfe');
                  if (!await folder.exists()) {
                    await folder.create(recursive: true);
                  }

                  final filePath = '${folder.path}/commandes_internes_${DateTime.now().millisecondsSinceEpoch}.pdf';
                  final file = File(filePath);
                  await file.writeAsBytes(pdfBytes);

                  if (!await file.exists()) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Échec de la création du fichier'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  final result = await OpenFile.open(filePath);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.type == ResultType.done
                          ? 'PDF sauvegardé dans : ${file.path}'
                          : "Erreur: ${result.message}"),
                        backgroundColor: result.type == ResultType.done ? Colors.green : Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur grave: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: Icon(Icons.download, color: theme.iconColor, size: 30),
            ),
          ),
          if ((userData?['is_staff'] ?? false) || (myPrivileges?['add_internalorder'] ?? false))
            Positioned(
              right: 15,
              bottom: 60,
              child: FloatingActionButton(
                onPressed: () => _showAddInternalOrderDialog(appData),
                backgroundColor: theme.buttonColor,
                elevation: 4,
                child: Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(InternalOrder order) {
    final theme = Provider.of<ThemeProvider>(context);
    final appData = Provider.of<AppData>(context);

    return GestureDetector(
      onTap: () async {
        final updatedOrder = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsInternalOrderScreen(order: order),
          ),
        ).then((_) {
          setState(() {});
        });

        if (updatedOrder != null) {
          setState(() {
            final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
            if (index != -1) {
              _orders[index] = updatedOrder;
            }
          });
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(order.orderNum, style: TextStyle(color: theme.secondaryTextColor)),
                  const Spacer(),
                  Text('${order.date.day}/${order.date.month}/${order.date.year}', 
                      style: TextStyle(color: theme.secondaryTextColor)),
                ],
              ),
              Row(
                children: [
                  Text('Articles: ${order.items.length}', 
                      style: TextStyle(color: theme.secondaryTextColor)),
                  const Spacer(),
                  Text('${order.totalPrice.toStringAsFixed(2)} DH', 
                      style: TextStyle(color: theme.secondaryTextColor)),
                ],
              ),
              Row(
                children: [
                  Text(_getPaymentMethodText(order.paymentMethod), 
                      style: TextStyle(color: theme.secondaryTextColor)),
                  const Spacer(),
                  Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: order.status == OrderStatus.completed ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Type: ${order.typeOrder == TypeOrder.online ? 'En ligne' : 'En magasin'}',
                    style: TextStyle(fontStyle: FontStyle.italic, color: theme.secondaryTextColor),
                  ),
                ],
              ),
            ],
          ),
          trailing: ((userData?['is_staff'] ?? false) || 
                   (myPrivileges?['edit_internalorder'] ?? false) || 
                   (myPrivileges?['delete_internalorder'] ?? false))
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((userData?['is_staff'] ?? false) || (myPrivileges?['edit_internalorder'] ?? false))
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(appData, order),
                      ),
                    if ((userData?['is_staff'] ?? false) || (myPrivileges?['delete_internalorder'] ?? false))
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(appData, order),
                      ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.processing:
        return 'En traitement';
      case OrderStatus.toPay:
        return 'À payer';
      case OrderStatus.completed:
        return 'Terminée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.card:
        return 'Carte';
      case PaymentMethod.virement:
        return 'Virement';
      case PaymentMethod.cheque:
        return 'Chèque';
    }
  }

  void _showAddInternalOrderDialog(AppData appData) {
    showDialog(
      context: context,
      builder: (context) => AddInternalOrderScreen(
        onOrderAdded: (newOrder) async {
          await appData.fetchInternalOrders();
          await _refreshOption();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande ajoutée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteDialog(AppData appData, InternalOrder order) {
    showDialog(
      context: context,
      builder: (context) => DeleteOrderDialog(
        orderId: order.orderNum,
        onConfirm: () async {
            if (order.id != null) {
              await _handleDeleteOrder(appData, order);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur : ID de la commande est null'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
        },
      ),
    );
  }

  Future<void> _handleDeleteOrder(AppData appData, InternalOrder order) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      
      final success = await appData.deleteInternalOrder(order.id!);
      
      
      if (success && mounted) {
        await appData.fetchInternalOrders();
        await _refreshOption();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande de ${order.clientName} supprimé avec succès'),
            backgroundColor: Colors.red,
          ),
        );
        
        Provider.of<ActivityService>(context, listen: false)
          .addActivity("Suppression d'une commande de: ${order.clientName}", 'delete');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(AppData appData, InternalOrder order) {
    showDialog(
      context: context,
      builder: (context) => EditInternalOrderScreen(
        order: order,
        onOrderUpdated: (updatedOrder) async {
          await appData.fetchInternalOrders();
          await _refreshOption();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande mise à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}