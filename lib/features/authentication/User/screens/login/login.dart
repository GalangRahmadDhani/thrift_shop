import 'package:ecommerce_app/common/styles/spacing_styles.dart';
import 'package:ecommerce_app/features/authentication/User/screens/login/widgets/login_form.dart';
import 'package:ecommerce_app/features/authentication/User/screens/login/widgets/login_header.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              // Logo, Judul, & Sub Judul
              TLoginHeader(),

              // Form
              TLoginForm(),

              // Divider
              // TFormDivider(dividerText: TTexts.orSignInWith.capitalize!),
              SizedBox(height: TSizes.spaceBtwSections,),

              // Footer
              // const TSocialButtons(),
            ],
          ),
        ),
      )
    );
  }
}
