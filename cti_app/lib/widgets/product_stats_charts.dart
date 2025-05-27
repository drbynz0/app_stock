import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '/models/product_sales.dart';

class TopProductsChart extends StatelessWidget {
  final List<ProductSales> products;
  final int maxItems;
  final bool showQuantity;

  const TopProductsChart({
    super.key,
    required this.products,
    this.maxItems = 5,
    this.showQuantity = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final sortedProducts = List<ProductSales>.from(products)
      ..sort((a, b) => showQuantity 
          ? b.quantitySold.compareTo(a.quantitySold) 
          : b.totalAmount.compareTo(a.totalAmount));
    
    final topProducts = sortedProducts.take(maxItems).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: theme.shadowColor,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            showQuantity 
                ? 'Top $maxItems produits (quantité vendue)' 
                : 'Top $maxItems produits (chiffre d\'affaires)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
              ),
              primaryYAxis: NumericAxis(
                numberFormat: showQuantity
                    ? null 
                    : NumberFormat.currency(locale: 'fr', symbol: ''),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: showQuantity
                    ? 'point.x\nQuantité: point.y'
                    : 'point.x\nCA: point.y MAD',
              ),
              series: <CartesianSeries<dynamic, dynamic>>[
                BarSeries<ProductSales, String>(
                  dataSource: topProducts,
                  xValueMapper: (ProductSales sales, _) => sales.productName,
                  yValueMapper: (ProductSales sales, _) => 
                      showQuantity ? sales.quantitySold : sales.totalAmount,
                  color: const Color(0xFF4BB543),
                  width: 0.6,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.auto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}