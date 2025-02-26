import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app/common/styles/spacing_styles.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final String orderId;
  final String transactionId;
  final String paymentMethod;
  final double amount;
  final DateTime paymentDate;
  final String customerName;
  final String status;
  final String? virtualAccount;
  final String? pdfUrl;

  const PaymentReceiptScreen({
    super.key,
    required this.orderId,
    required this.transactionId,
    required this.paymentMethod,
    required this.amount,
    required this.paymentDate,
    required this.customerName,
    required this.status,
    this.virtualAccount,
    this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight * 1.5,
          child: Column(
            children: [
              // Animation and Success Message
              Lottie.asset(
                TImages.successFullyRegisterAnimation, // Make sure to add this to your image strings
                width: THelperFunctions.screenWidth() * 0.5,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Header Text
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Your transaction has been completed',
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Payment Details Card
              Container(
                padding: const EdgeInsets.all(TSizes.lg),
                decoration: BoxDecoration(
                  color: dark ? TColors.darkerGrey : Colors.white,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    
                    // Details List
                    _buildDetailRow('Order ID', orderId),
                    _buildDetailRow('Transaction ID', transactionId),
                    _buildDetailRow('Payment Method', paymentMethod),
                    if (virtualAccount != null) 
                      _buildDetailRow('Virtual Account', virtualAccount!),
                    _buildDetailRow(
                      'Amount',
                      currencyFormatter.format(amount),
                      valueColor: Colors.green,
                    ),
                    _buildDetailRow(
                      'Date',
                      DateFormat('dd MMM yyyy, HH:mm').format(paymentDate),
                    ),
                    _buildDetailRow('Customer', customerName),
                    _buildDetailRow('Status', status, valueColor: Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implement download functionality
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(TSizes.md),
                      ),
                      icon: const Icon(Iconsax.document_download),
                      label: const Text('Download Receipt'),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implement share functionality
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(TSizes.md),
                      ),
                      icon: const Icon(Iconsax.share),
                      label: const Text('Share Receipt'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}