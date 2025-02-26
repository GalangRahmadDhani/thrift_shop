import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../widgets/admin_sidebar.dart';
import './widgets/banner_add_form.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';

class BannerAddScreen extends ConsumerWidget {
  const BannerAddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldBannerKey = GlobalKey<ScaffoldState>();
    final dark = THelperFunctions.isDarkMode(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // Ensure user is logged in
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first'),
        ),
      );
    }

    return Scaffold(
      key: scaffoldBannerKey,
      appBar: TAppBar(
        title: const Text('Add Banner'),
        showBackArrow: true,
        leadingOnPressed: () => scaffoldBannerKey.currentState?.openDrawer(),
        backgroundColor: dark ? TColors.dark : TColors.light,
      ),
      drawer: const AdminSidebar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: BannerAddForm(adminUid: currentUser.uid),
        ),
      ),
    );
  }
}