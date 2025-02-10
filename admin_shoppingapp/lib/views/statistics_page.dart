
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String selectedTimeRange = 'Week'; // 'Week', 'Month', 'Year'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          DropdownButton<String>(
            value: selectedTimeRange,
            items: ['Week', 'Month', 'Year']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedTimeRange = value;
                });
              }
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          // Calculate analytics data
          final revenueData = _calculateRevenueData(adminProvider.orders);
          // final productData = _calculateProductData(adminProvider.orders);
          final userData = _calculateUserData(adminProvider.orders);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards Row
                Row(
                  children: [
                    _buildSummaryCard(
                      'Total Revenue',
                      '₹${_calculateTotalRevenue(adminProvider.orders)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                    _buildSummaryCard(
                      'Total Orders',
                      adminProvider.totalOrders.toString(),
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                    _buildSummaryCard(
                      'Active Users',
                      userData.length.toString(),
                      Icons.people,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Revenue Chart
                _buildChartCard(
                  'Revenue Trend',
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      _revenueData(revenueData),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Product Performance
                // _buildChartCard(
                //   'Top Products',
                //   SizedBox(
                //     height: 300,
                //     child: BarChart(
                //       _productData(productData),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),

                // Order Status Distribution
                _buildChartCard(
                  'Order Status',
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      _orderStatusData(adminProvider),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  LineChartData _revenueData(List<Map<String, dynamic>> revenueData) {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < revenueData.length) {
                return Text(
                  DateFormat('dd/MM').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          revenueData[value.toInt()]['date'])),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: revenueData
              .asMap()
              .entries
              .map((entry) => FlSpot(
                  entry.key.toDouble(), entry.value['revenue'].toDouble()))
              .toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }

  BarChartData _productData(List<Map<String, dynamic>> productData) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: productData.isEmpty
          ? 10
          : productData
              .map((e) => e['quantity'])
              .reduce((a, b) => a > b ? a : b)
              .toDouble(),
      barGroups: productData
          .asMap()
          .entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value['quantity'].toDouble(),
                  color: Colors.blue,
                ),
              ],
            ),
          )
          .toList(),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < productData.length) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    productData[value.toInt()]['name'],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
    );
  }

  PieChartData _orderStatusData(AdminProvider provider) {
    final delivered =
        provider.ordersDelivered.toDouble();
    final cancelled =
        provider.ordersCancelled.toDouble();
    final onTheWay =
        provider.ordersOnTheWay.toDouble();
    final pending =
        provider.orderPendingProcess.toDouble();

    return PieChartData(
      sections: [
        PieChartSectionData(
          color: Colors.green,
          value: delivered,
          title: 'Delivered\n${delivered.toInt()}',
          radius: 100,
        ),
        PieChartSectionData(
          color: Colors.red,
          value: cancelled,
          title: 'Cancelled\n${cancelled.toInt()}',
          radius: 100,
        ),
        PieChartSectionData(
          color: Colors.orange,
          value: onTheWay,
          title: 'On Way\n${onTheWay.toInt()}',
          radius: 100,
        ),
        PieChartSectionData(
          color: Colors.blue,
          value: pending,
          title: 'Pending\n${pending.toInt()}',
          radius: 100,
        ),
      ],
    );
  }

  double _calculateTotalRevenue(List<QueryDocumentSnapshot> orders) {
    return orders.fold(
        0.0, (sum, order) => sum + (order['total'] as num).toDouble());
  }

  List<Map<String, dynamic>> _calculateRevenueData(
      List<QueryDocumentSnapshot> orders) {
    final Map<String, double> dailyRevenue = {};
    
    for (var order in orders) {
      final date = DateTime.fromMillisecondsSinceEpoch(order['created_at']);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      dailyRevenue[dateStr] =
          (dailyRevenue[dateStr] ?? 0) + (order['total'] as num).toDouble();
    }

    return dailyRevenue.entries
        .map((e) => {
              'date': DateFormat('yyyy-MM-dd')
                  .parse(e.key)
                  .millisecondsSinceEpoch,
              'revenue': e.value,
            })
        .toList()
      ..sort((a, b) => (a['date'] as int).compareTo(b['date'] as int));
  }

  // List<Map<String, dynamic>> _calculateProductData(
  //     List<QueryDocumentSnapshot> orders) {
  //   final Map<String, int> productQuantities = {};

  //   for (var order in orders) {
  //     final products = order['products'] as List;
  //     for (var product in products) {
  //       final name = product['name'] as String;
  //       final quantity = product['quantity'] as int;
  //       productQuantities[name] = (productQuantities[name] ?? 0) + quantity;
  //     }
  //   }

  // return productQuantities.entries
  //   .map((e) => {'name': e.key, 'quantity': e.value})
  //   .toList()
  // ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int))
  // ..take(5)
  // .toList();

  // }

  List<Map<String, dynamic>> _calculateUserData(
      List<QueryDocumentSnapshot> orders) {
    final Map<String, int> userOrders = {};

    for (var order in orders) {
      final user = order['name'] as String;
      userOrders[user] = (userOrders[user] ?? 0) + 1;
    }

 return userOrders.entries
    .map((e) => {'name': e.key, 'orders': e.value})
    .toList()
  ..sort((a, b) => (b['orders'] as int).compareTo(a['orders'] as int))
  ..take(5)
  .toList();
      }
}