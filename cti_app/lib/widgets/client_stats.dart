import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '/models/internal_order.dart';

class CustomerBehaviorChart extends StatelessWidget {
  final List<InternalOrder> orders;

  const CustomerBehaviorChart({super.key, required this.orders});

  // Méthode pour classer les clients selon leur comportement
  List<CustomerBehaviorData> _analyzeCustomerBehavior() {
    final clientOrders = <int?, List<InternalOrder>>{};
    
    // Grouper les commandes par client
    for (var order in orders) {
      if (!clientOrders.containsKey(order.clientId)) {
        clientOrders[order.clientId] = [];
      }
      clientOrders[order.clientId]!.add(order);
    }
    
    // Analyser le comportement de chaque client
    int excellentCount = 0;
    int goodCount = 0;
    int poorCount = 0;
    
    for (var clientId in clientOrders.keys) {
      final clientOrdersList = clientOrders[clientId]!;
      final orderCount = clientOrdersList.length;
      final totalAmount = clientOrdersList.fold(0.0, (sum, order) => sum + order.totalPrice);
      final avgAmount = totalAmount / orderCount;
      final completedCount = clientOrdersList.where((o) => o.status == OrderStatus.completed).length;
      final completionRate = completedCount / orderCount;
      
      // Classer le client selon son comportement
      if (avgAmount > 150 && completionRate > 0.8 && orderCount >= 3) {
        excellentCount++;
      } else if (avgAmount > 50 && completionRate > 0.5) {
        goodCount++;
      } else {
        poorCount++;
      }
    }
    
    final totalClients = clientOrders.keys.length;
    
    return [
      CustomerBehaviorData(
        category: 'Excellent',
        count: excellentCount,
        percentage: totalClients > 0 ? ((excellentCount / totalClients) * 100).round() : 0,
        color: Colors.green,
      ),
      CustomerBehaviorData(
        category: 'Good',
        count: goodCount,
        percentage: totalClients > 0 ? ((goodCount / totalClients) * 100).round() : 0,
        color: Colors.blue,
      ),
      CustomerBehaviorData(
        category: 'Poor',
        count: poorCount,
        percentage: totalClients > 0 ? ((poorCount / totalClients) * 100).round() : 0,
        color: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final behaviorData = _analyzeCustomerBehavior();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comportement des clients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Diagramme circulaire
            SizedBox(
              height: 250,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CircularSeries>[
                  PieSeries<CustomerBehaviorData, String>(
                    dataSource: behaviorData,
                    xValueMapper: (CustomerBehaviorData data, _) => data.category,
                    yValueMapper: (CustomerBehaviorData data, _) => data.percentage,
                    pointColorMapper: (CustomerBehaviorData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.inside,
                      textStyle: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    explode: true,
                    explodeIndex: 0,
                  ),
                ],
              ),
            ),
            // Légende détaillée
            const SizedBox(height: 16),
            Column(
              children: behaviorData.map((data) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: data.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.category,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${data.count} clients (${data.percentage}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerBehaviorData {
  final String category;
  final int count;
  final int percentage;
  final Color color;

  CustomerBehaviorData({
    required this.category,
    required this.count,
    required this.percentage,
    required this.color,
  });
}