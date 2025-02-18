import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/authentication/Admin/widgets/admin_sidebar.dart';
import 'package:ecommerce_app/features/authentication/Admin/widgets/custom_card.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: TAppBar(
        title: const Text('Admin Dashboard'),
        leadingIcon: Icons.menu,
        leadingOnPressed: () => scaffoldKey.currentState?.openDrawer(),
        backgroundColor: dark ? TColors.dark : TColors.light,
      ),
      drawer: const AdminSidebar(),
      body: Container(
        color: dark ? TColors.darkerGrey : TColors.white,
        padding: const EdgeInsets.all(TSizes.md),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomCard(
                  title: 'Customer Terdaftar',
                  value: '500',
                ),
                SizedBox(width: 16),
                CustomCard(
                  title: 'Stok Barang',
                  value: '500',
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                CustomCard(
                  title: 'Total Pendapatan',
                  value: 'Rp 5.000.000',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

