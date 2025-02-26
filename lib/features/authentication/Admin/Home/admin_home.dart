import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/authentication/Admin/controller/transaction_controller.dart';
import 'package:ecommerce_app/features/authentication/Admin/widgets/admin_sidebar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ... existing imports ...

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final transactionController = Get.put(TransactionController());
  final String _selectedPeriod = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldAdminHomeKey = GlobalKey<ScaffoldState>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      key: scaffoldAdminHomeKey,
      appBar: TAppBar(
        title: const Text('Admin Dashboard'),
        leadingIcon: Icons.menu,
        leadingOnPressed: () => scaffoldAdminHomeKey.currentState?.openDrawer(),
        backgroundColor: dark ? TColors.dark : TColors.light,
      ),
      drawer: const AdminSidebar(),
      body: Container(
        color: dark ? TColors.darkerGrey : TColors.white,
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          children: [
            // Period Selection Dropdown
            Obx(() => DropdownButton<String>(
              value: transactionController.selectedPeriod.value,
              items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: transactionController.changePeriod, // Now accepts nullable String
            )),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Chart Card
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Obx(() {
                    if (transactionController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(
                          text: transactionController.selectedPeriod.value
                        ),
                        labelRotation: 45,
                      ),
                      primaryYAxis: NumericAxis(
                        title: const AxisTitle(text: 'Revenue (IDR)'),
                        numberFormat: NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ),
                      ),
                      title: ChartTitle(
                        text: '${transactionController.selectedPeriod.value} Revenue'
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<RevenueData, String>>[
                        ColumnSeries<RevenueData, String>(
                          dataSource: transactionController.chartData, // Using controller's chartData
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
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the RevenueData class as is
class RevenueData {
  final String month;
  final double revenue;

  RevenueData(this.month, this.revenue);
  
  @override
  String toString() => 'RevenueData(month: $month, revenue: $revenue)';
}