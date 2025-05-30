import 'package:flutter/material.dart';
import '/models/internal_order.dart';
import '/models/external_order.dart';
import '/models/product.dart';
import '/models/sale_record.dart';
import '/widgets/order_stats_charts.dart';
import '/widgets/product_stats_charts.dart';
import '/models/product_sales.dart';
import '/widgets/client_stats.dart';

class StatsPage extends StatefulWidget {
  final List<InternalOrder> internalOrders;
  final List<ExternalOrder> externalOrders;
    final List<Product> allProducts;

  const StatsPage({
    super.key,
    required this.internalOrders,
    required this.externalOrders,
    required this.allProducts,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _currentTab = 0;
  late List<SaleRecord> _allRecords;
  late List<ProductSales> _productStats;

  @override
  void initState() {
    super.initState();
    _allRecords = [
      ...widget.internalOrders.map((o) => InternalOrderRecord(o)),
      ...widget.externalOrders.map((o) => ExternalOrderRecord(o)),
    ];
    _productStats = _calculateProductStats();
  }

  List<ProductSales> _calculateProductStats() {
    final productMap = <String, ProductSales>{};

    // Traitement des commandes internes
    for (final order in widget.internalOrders) {
      for (final item in order.items) {
        final product = widget.allProducts.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product.empty(),
        );

        productMap.update(
          product.code,
          (existing) => ProductSales(
            productId: existing.productId,
            productName: existing.productName,
            quantitySold: existing.quantitySold + item.quantity,
            totalAmount: existing.totalAmount + (product.price * item.quantity),
            imageUrl: product.images.isNotEmpty ? product.images.first : null,
          ),
          ifAbsent: () => ProductSales(
            productId: product.code,
            productName: product.name,
            quantitySold: item.quantity,
            totalAmount: product.price * item.quantity,
            imageUrl: product.images.isNotEmpty ? product.images.first : null,
          ),
        );
      }
    }
    return productMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Statistiques', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Statistiques des commandes
            _buildOrdersStatsSection(),
            
            const SizedBox(height: 32),
            
            // Section Statistiques des produits
            _buildProductsStatsSection(),
            const SizedBox(height: 32),
            CustomerBehaviorChart(orders: widget.internalOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques des commandes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSegmentedControl(),
        const SizedBox(height: 16),
        _buildCurrentOrdersChart(),
      ],
    );
  }

   Widget _buildProductsStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques des produits',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TopProductsChart(
          products: _productStats,
          showQuantity: true,
          maxItems: 5,
        ),
        const SizedBox(height: 16),
        TopProductsChart(
          products: _productStats,
          showQuantity: false,
          maxItems: 5,
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabButton('7 Jours', 0)),
            Expanded(child: _buildTabButton('12 Mois', 1)),
            Expanded(child: _buildTabButton('5 Ans', 2)),
          ],
        ),
      ),
    );
  }


  Widget _buildTabButton(String text, int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: _currentTab == index 
              ? const Color(0xFF004A99) 
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => setState(() => _currentTab = index),
        child: Text(
          text,
          style: TextStyle(
            color: _currentTab == index ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

    Widget _buildCurrentOrdersChart() {
      
    switch (_currentTab) {
      case 0:
        return DailySalesChart(records: _allRecords,);
      case 1:
        return MonthlySalesChart(records: _allRecords,);
      case 2:
        return YearlySalesChart(records: _allRecords,);
      default:
        return MonthlySalesChart(records: _allRecords,);
    }
  }
}