import 'package:ecommerce_app/bindings/general_binding.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App ({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
    themeMode: ThemeMode.system,
    theme: TAppTheme.lightTheme,
    darkTheme: TAppTheme.darkTheme,
    initialBinding: GeneralBinding(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: TColors.primary, body: Center(child: CircularProgressIndicator(color: Colors.white,),),),
      // home: const OnboardingScreen(),
    );
  }
}
