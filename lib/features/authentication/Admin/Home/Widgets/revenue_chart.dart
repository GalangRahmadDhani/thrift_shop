import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Transaction')
          .orderBy('createdAtTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        Map<String, double> monthlyRevenue = {};
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          var amount = (data['amount'] ?? 0).toDouble();
          var date = (data['createdAtTimestamp'] as Timestamp).toDate();
          var monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          
          monthlyRevenue[monthYear] = (monthlyRevenue[monthYear] ?? 0) + amount;
        }

        List<RevenueData> chartData = monthlyRevenue.entries.map((e) {
          return RevenueData(e.key, e.value);
        }).toList()
          ..sort((a, b) => a.month.compareTo(b.month));

        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(
            title: AxisTitle(text: 'Month'),
          ),
          primaryYAxis: NumericAxis(
            title: const AxisTitle(text: 'Revenue (IDR)'),
            numberFormat: NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ),
          ),
          title: const ChartTitle(text: 'Monthly Revenue'),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries<RevenueData, String>>[
            ColumnSeries<RevenueData, String>(
              dataSource: chartData,
              xValueMapper: (RevenueData data, _) => data.month,
              yValueMapper: (RevenueData data, _) => data.revenue,
              name: 'Revenue',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                angle: 270,
              ),
            )
          ],
        );
      },
    );
  }
}

class RevenueData {
  final String month;
  final double revenue;

  RevenueData(this.month, this.revenue);
}