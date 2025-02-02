import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/shop/screens/order/widgets/order_list.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appbar
      appBar: TAppBar(title: Text('Pesanan Saya', style: Theme.of(context).textTheme.headlineSmall,),),
      body: const Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
      // Pesanan
        child: TOrderListItems()
      ),

      
    );
  }
}