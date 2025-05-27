import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '/models/sale_record.dart';

class SalesData {
  final String period;
  final double totalSales;
  final Color? color;

  SalesData({required this.period, required this.totalSales, this.color});
}

class DailySalesChart extends StatelessWidget {
  final List<SaleRecord> records;
  final List<Color> colors;

  const DailySalesChart({
    super.key, 
    required this.records,
    this.colors = const [
      Color(0xFF004A99),    // Bleu pour les internes
      Color(0xFFEF8827),    // Orange pour les externes
    ],
  });

  @override
  Widget build(BuildContext context) {
    final data = _getWeeklySalesData();
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: _chartDecoration(context),
      height: 300,
      padding: const EdgeInsets.all(10),
      child: SfCartesianChart(
        title: const ChartTitle(text: 'Ventes des 7 derniers jours'),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.top,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        primaryXAxis: CategoryAxis(
          title: const AxisTitle(text: 'Jours'),
          labelRotation: -45,
        ),
        primaryYAxis: NumericAxis(
          title: const AxisTitle(text: 'Montant (MAD)'),
          numberFormat: NumberFormat.currency(locale: 'fr', symbol: ''),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: data.map((seriesData) => ColumnSeries<SalesData, String>(
          dataSource: seriesData,
          xValueMapper: (SalesData sales, _) => sales.period,
          yValueMapper: (SalesData sales, _) => sales.totalSales,
          name: seriesData.first.color == colors[0] ? 'Interne' : 'Externe', // Légende
          color: seriesData.first.color,
          width: screenWidth > 400 ? 0.4 : 0.3,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )).toList(),
      ),
    );
  }

  List<List<SalesData>> _getWeeklySalesData() {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    final dateFormat = DateFormat('E dd'); // Format "Lun 15"

    final internalRecords = records.whereType<InternalOrderRecord>().toList();
    final externalRecords = records.whereType<ExternalOrderRecord>().toList();

    return [
      _generateSeriesData(internalRecords, weekDays, dateFormat, colors[0]),
      _generateSeriesData(externalRecords, weekDays, dateFormat, colors[1]),
    ];
  }

  List<SalesData> _generateSeriesData(
    List<SaleRecord> records, 
    List<DateTime> days, 
    DateFormat format,
    Color color,
  ) {
    final dailySales = <String, double>{};
    
    // Initialiser tous les jours
    for (final day in days) {
      dailySales[format.format(day)] = 0;
    }

    // Remplir avec les données existantes
    for (final record in records) {
      if (record.date.isAfter(days.first.subtract(const Duration(days: 1)))) {
        final dayKey = format.format(record.date);
        dailySales[dayKey] = (dailySales[dayKey] ?? 0) + record.amount;
      }
    }

    return dailySales.entries
        .map((e) => SalesData(period: e.key, totalSales: e.value, color: color))
        .toList();
  }
}

class MonthlySalesChart extends StatelessWidget {
  final List<SaleRecord> records;
  final List<Color> colors;

  const MonthlySalesChart({
    super.key, 
    required this.records,
    this.colors = const [
      Color(0xFF004A99),
      Color(0xFFEF8827),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final data = _getYearlySalesData();
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(12),
      decoration: _chartDecoration(context),
      child: SfCartesianChart(
        title: const ChartTitle(text: 'Ventes mensuelles - Année en cours'),
        legend: Legend(isVisible: true, position: LegendPosition.top),
        primaryXAxis: CategoryAxis(
          title: const AxisTitle(text: 'Mois'),
          labelRotation: screenWidth > 400 ? -45 : -90,
        ),
        primaryYAxis: NumericAxis(
          title: const AxisTitle(text: 'Montant (MAD)'),
          numberFormat: NumberFormat.currency(locale: 'fr', symbol: ''),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'series.name : point.y MAD',
        ),
        series: <CartesianSeries<dynamic, dynamic>>[
          LineSeries<SalesData, String>(
            dataSource: data[0],
            xValueMapper: (SalesData sales, _) => sales.period,
            yValueMapper: (SalesData sales, _) => sales.totalSales,
            name: 'Interne',
            color: colors[0],
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
          LineSeries<SalesData, String>(
            dataSource: data[1],
            xValueMapper: (SalesData sales, _) => sales.period,
            yValueMapper: (SalesData sales, _) => sales.totalSales,
            name: 'Externe',
            color: colors[1],
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  List<List<SalesData>> _getYearlySalesData() {
    final currentYear = DateTime.now().year;
    const monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 
                        'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];

    final internalRecords = records.whereType<InternalOrderRecord>().toList();
    final externalRecords = records.whereType<ExternalOrderRecord>().toList();

    return [
      _generateMonthlyData(internalRecords, currentYear, monthNames, colors[0]),
      _generateMonthlyData(externalRecords, currentYear, monthNames, colors[1]),
    ];
  }

  List<SalesData> _generateMonthlyData(
    List<SaleRecord> records,
    int year,
    List<String> monthNames,
    Color color,
  ) {
    final monthlySales = <String, double>{};
    
    // Initialiser tous les mois
    for (final month in monthNames) {
      monthlySales[month] = 0;
    }

    // Remplir avec les données existantes
    for (final record in records) {
      if (record.date.year == year) {
        final month = monthNames[record.date.month - 1];
        monthlySales[month] = (monthlySales[month] ?? 0) + record.amount;
      }
    }

    return monthlySales.entries
        .map((e) => SalesData(period: e.key, totalSales: e.value, color: color))
        .toList();
  }
}

class YearlySalesChart extends StatelessWidget {
  final List<SaleRecord> records;
  final List<Color> colors;

  const YearlySalesChart({
    super.key, 
    required this.records,
    this.colors = const [
      Color(0xFF004A99),
      Color(0xFFEF8827),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final data = _getLast5YearsData();
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(12),
      decoration: _chartDecoration(context),
      child: SfCartesianChart(
        title: const ChartTitle(text: 'Ventes annuelles - 5 dernières années'),
        legend: Legend(isVisible: true, position: LegendPosition.top),
        primaryXAxis: CategoryAxis(
          title: const AxisTitle(text: 'Années'),
          labelRotation: screenWidth > 400 ? 0 : -45,
        ),
        primaryYAxis: NumericAxis(
          title: const AxisTitle(text: 'Montant (MAD)'),
          numberFormat: NumberFormat.currency(locale: 'fr', symbol: ''),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'series.name : point.y MAD',
        ),
        series: <CartesianSeries<dynamic, dynamic>>[
          BarSeries<SalesData, String>(
            dataSource: data[0],
            xValueMapper: (SalesData sales, _) => sales.period,
            yValueMapper: (SalesData sales, _) => sales.totalSales,
            name: 'Interne',
            color: colors[0],
            width: 0.5,
            spacing: 0.1,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
          BarSeries<SalesData, String>(
            dataSource: data[1],
            xValueMapper: (SalesData sales, _) => sales.period,
            yValueMapper: (SalesData sales, _) => sales.totalSales,
            name: 'Externe',
            color: colors[1],
            width: 0.5,
            spacing: 0.1,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  List<List<SalesData>> _getLast5YearsData() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - 4 + index);

    final internalRecords = records.whereType<InternalOrderRecord>().toList();
    final externalRecords = records.whereType<ExternalOrderRecord>().toList();

    return [
      _generateYearlyData(internalRecords, years, colors[0]),
      _generateYearlyData(externalRecords, years, colors[1]),
    ];
  }

  List<SalesData> _generateYearlyData(
    List<SaleRecord> records,
    List<int> years,
    Color color,
  ) {
    final yearlySales = <String, double>{};
    
    // Initialiser toutes les années
    for (final year in years) {
      yearlySales[year.toString()] = 0;
    }

    // Remplir avec les données existantes
    for (final record in records) {
      if (years.contains(record.date.year)) {
        final year = record.date.year.toString();
        yearlySales[year] = (yearlySales[year] ?? 0) + record.amount;
      }
    }

    return yearlySales.entries
        .map((e) => SalesData(period: e.key, totalSales: e.value, color: color))
        .toList();
  }
}

BoxDecoration _chartDecoration(BuildContext context) {
      final theme = Provider.of<ThemeProvider>(context);
  return BoxDecoration(
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
    border: Border.all(
      color: theme.borderColor,
      width: 1,
    ),
  );
}