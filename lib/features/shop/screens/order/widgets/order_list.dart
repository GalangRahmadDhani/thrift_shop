import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/common/widgets/custom_shape/container/rounded_container.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TOrderListItems extends StatelessWidget {
  const TOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    // Previous code remains the same until orderData declaration
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada pesanan'));
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final List<dynamic> statusHistory = orderData['statusHistory'] ?? [];
            final createdAt = orderData['createdAt'];
            
            return TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous widget tree remains the same until the date formatting
                  Row(
                    children: [
                      const Icon(Iconsax.ship),
                      const SizedBox(width: TSizes.spaceBtwItems / 2),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderData['statusPesanan'] ?? 'Status tidak tersedia',
                              style: Theme.of(context).textTheme.bodyLarge!.apply(
                                    color: TColors.primary,
                                    fontWeightDelta: 1,
                                  ),
                            ),
                            Text(
                              _formatDateTime(createdAt),
                              style: Theme.of(context).textTheme.headlineSmall,
                            )
                          ],
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(Iconsax.arrow_right_34, size: TSizes.iconSm),
                      // )
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Iconsax.tag),
                            const SizedBox(width: TSizes.spaceBtwItems / 2),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order ID',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    orderData['orderId'] ?? 'N/A',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Iconsax.money),
                            const SizedBox(width: TSizes.spaceBtwItems / 2),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text( 
                                    NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(num.tryParse(orderData['amount'].toString()) ?? 0),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _buildStatusTimeline(context, statusHistory),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(dateTime.toDate());
    } else if (dateTime is String) {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateTime));
    }
    return 'Invalid Date';
  }

  List<Widget> _buildStatusTimeline(BuildContext context, List<dynamic> statusHistory) {
    final List<String> allStatuses = [
      'Sedang Di Proses',
      'Sedang Di Kemas',
      'Dalam Perjalanan',
      'Selesai'
    ];
    
    return List.generate(allStatuses.length, (index) {
      final status = allStatuses[index];
      final isCompleted = statusHistory.any((hist) => hist['status'] == status);
      final isFirst = index == 0;
      final isLast = index == allStatuses.length - 1;
      
      dynamic timestamp;
      if (isCompleted) {
        final historyEntry = statusHistory.firstWhere(
          (hist) => hist['status'] == status,
          orElse: () => null,
        );
        if (historyEntry != null) {
          timestamp = historyEntry['timestamp'];
        }
      }

      String formattedDate = '';
      if (timestamp != null) {
        formattedDate = _formatDateTime(timestamp);
      }

      return SizedBox(
        width: 120,
        child: TimelineTile(
          axis: TimelineAxis.horizontal,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: isCompleted ? TColors.primary : TColors.grey,
            iconStyle: IconStyle(
              iconData: isCompleted ? Icons.check : Icons.circle,
              color: Colors.white,
            ),
          ),
          beforeLineStyle: LineStyle(
            color: isCompleted ? TColors.primary : TColors.grey,
          ),
          afterLineStyle: LineStyle(
            color: index < statusHistory.length - 1 ? TColors.primary : TColors.grey,
          ),
          endChild: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: isCompleted ? TColors.primary : TColors.grey,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}