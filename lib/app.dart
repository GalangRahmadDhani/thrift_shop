import 'package:ecommerce_app/bindings/general_binding.dart';
import 'package:ecommerce_app/data/repositories/product/product_repository.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App ({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    Get.put(ProductRepository());
    
    return GetMaterialApp(
    themeMode: ThemeMode.system,
    theme: TAppTheme.lightTheme,
    darkTheme: TAppTheme.darkTheme,
    initialBinding: GeneralBinding(),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(backgroundColor: TColors.primary, body: Center(child: CircularProgressIndicator(color: Colors.white,),),),
      // home: const OnboardingScreen(),
    );
  }
}
