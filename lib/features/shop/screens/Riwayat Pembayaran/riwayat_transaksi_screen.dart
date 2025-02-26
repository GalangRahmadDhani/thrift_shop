import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/transaction_service.dart';

class RiwayatTransaksiScreen extends StatelessWidget {
  RiwayatTransaksiScreen({super.key});

  final TransactionService _transactionService = TransactionService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  String getPaymentStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Menunggu Pembayaran';
      case 'SETTLEMENT':
        return 'Pembayaran Berhasil';
      case 'CAPTURE':
        return 'Pembayaran Berhasil';
      case 'DENY':
        return 'Pembayaran Ditolak';
      case 'CANCEL':
        return 'Pembayaran Dibatalkan';
      case 'EXPIRE':
        return 'Pembayaran Kadaluarsa';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SETTLEMENT':
      case 'CAPTURE':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'DENY':
      case 'CANCEL':
      case 'EXPIRE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _transactionService.getTransactions(userId),
        builder: (context, snapshot) {
          // Debug prints
          debugPrint('Connection state: ${snapshot.connectionState}');
          debugPrint('Has error: ${snapshot.hasError}');
          if (snapshot.hasError) debugPrint('Error: ${snapshot.error}');
          debugPrint('Has data: ${snapshot.hasData}');
          debugPrint('Doc count: ${snapshot.data?.docs.length ?? 0}');
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada transaksi'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = data['createdAt'] as Timestamp;
              final date = DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate());
              final orderItems = List<Map<String, dynamic>>.from(data['orderItems'] ?? []);
              final status = data['status'] as String;
              // Handle amount that might be string or num
              final amount = num.tryParse(data['amount'].toString()) ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    'Order ID: ${data['orderId']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Tanggal: $date'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          getPaymentStatusText(status),
                          style: TextStyle(
                            color: getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Produk:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...orderItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(item['productName']),
                                ),
                                Text('${item['quantity']}x'),
                                const SizedBox(width: 8),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(item['price']),
                                ),
                              ],
                            ),
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(amount),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (data['paymentType'] != null) ...[
                            const SizedBox(height: 8),
                            Text('Metode Pembayaran: ${data['paymentType']}'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}