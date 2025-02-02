import 'package:ecommerce_app/features/authentication/screens/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController{
  static OnBoardingController get instance => Get.find();

  // Variabel
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;
  // Update Current Index When Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  // Jump to The Spesific dot Selected Page
  void dotNavigationClick(index){
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  // Update Current Index & Jump to Next Page
  // void nextPage(){
  //   if(currentPageIndex.value == 2){
  //     Get.offAll(const LoginScreen());
  //   } else {
  //     int page = currentPageIndex.value + 1;
  //     pageController.jumpToPage(page);
  //   }
  // }

  void nextPage() {
    if (currentPageIndex.value == 2) {
      Get.offAll(
        () => const LoginScreen(),
        duration: const Duration(milliseconds: 500),
        transition: Transition.rightToLeftWithFade,
      );
    } else {
      int page = currentPageIndex.value + 1;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 500), // Durasi animasi
        curve: Curves.easeInOut, // Efek transisi animasi
      );
    }
  }

  // Update Current Index & Jump to the last Page
  void skipPage(){
    currentPageIndex.value = 2;
    pageController.animateToPage(
        2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}