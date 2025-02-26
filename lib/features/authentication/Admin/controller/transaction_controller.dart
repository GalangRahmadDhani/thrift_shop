import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/authentication/Admin/Home/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionController extends GetxController {
  static TransactionController get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  
  final selectedPeriod = 'Monthly'.obs;
  final isLoading = false.obs;
  final chartData = <RevenueData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactionData();
    // ever(selectedPeriod, (_) => fetchTransactionData());
  }

  // Updated to handle nullable String
  void changePeriod(String? period) {
    if (period != null) {
      selectedPeriod.value = period;
      fetchTransactionData();
    }
  }

Future<void> fetchTransactionData() async {
  try {
    isLoading.value = true;
    debugPrint('Fetching order data...');
    
    final snapshot = await _db
        .collection('Orders')
        .orderBy('createdAt', descending: true)
        .get();

    debugPrint('Found ${snapshot.docs.length} orders');
    Map<String, double> revenue = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      debugPrint('Processing order: ${doc.id}');
      
      final amount = data['amount'];
      final createdAt = data['createdAt'] as String?;
      
      if (amount == null || createdAt == null) {
        debugPrint('Skipping order ${doc.id}: amount=$amount, createdAt=$createdAt');
        continue;
      }
      
      // Convert amount to double
      final amountDouble = (amount is num) 
          ? amount.toDouble() 
          : double.tryParse(amount.toString()) ?? 0.0;

      // Parse ISO date string and convert to local time
      final date = DateTime.parse(createdAt).toLocal();
      debugPrint('Order date: $date');
      
      final period = _formatPeriod(date);
      revenue[period] = (revenue[period] ?? 0) + amountDouble;
      debugPrint('Added $amountDouble to $period. Total: ${revenue[period]}');
    }

    // Convert the map to sorted list
    var sortedEntries = revenue.entries.toList()
      ..sort((a, b) {
        // Parse the period strings back to DateTime for proper sorting
        DateTime dateA = _parsePeriodToDate(a.key);
        DateTime dateB = _parsePeriodToDate(b.key);
        return dateA.compareTo(dateB);
      });

    chartData.value = sortedEntries
        .map((e) => RevenueData(e.key, e.value))
        .toList();

    debugPrint('Chart data updated: ${chartData.length} periods');
    debugPrint('Chart data: ${chartData.map((e) => '${e.month}: ${e.revenue}')}');
      
  } catch (e, stackTrace) {
    debugPrint('Error fetching order data: $e');
    debugPrint(stackTrace.toString());
  } finally {
    isLoading.value = false;
  }
}

  DateTime _parsePeriodToDate(String period) {
    try {
      switch (selectedPeriod.value) {
        case 'Daily':
          return DateFormat('yyyy-MM-dd').parse(period);
        case 'Weekly':
          return DateFormat('yyyy-MM-dd').parse(period);
        case 'Monthly':
          return DateFormat('MMM yyyy').parse(period);
        case 'Yearly':
          return DateFormat('yyyy').parse(period);
        default:
          return DateFormat('MMM yyyy').parse(period);
      }
    } catch (e) {
      debugPrint('Error parsing period: $e');
      return DateTime.now();
    }
  }

  String _formatPeriod(DateTime date) {
    switch (selectedPeriod.value) {
      case 'Daily':
        return DateFormat('yyyy-MM-dd').format(date);
      case 'Weekly':
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        return DateFormat('yyyy-MM-dd').format(startOfWeek);
      case 'Monthly':
        return DateFormat('MMM yyyy').format(date);
      case 'Yearly':
        return DateFormat('yyyy').format(date);
      default:
        return DateFormat('MMM yyyy').format(date);
    }
  }
}