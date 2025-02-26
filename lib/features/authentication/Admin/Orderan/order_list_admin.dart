import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';


class OrderListAdminScreen extends StatelessWidget {
  const OrderListAdminScreen({super.key});

  String _formatPrice(dynamic price) {
    double numPrice = 0;
    
    try {
      if (price is String) {
        // Remove any non-numeric characters except decimal point
        String cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
        numPrice = double.parse(cleanPrice);
      } else if (price is num) {
        numPrice = price.toDouble();
      }
    } catch (e) {
      debugPrint('Error parsing price: $e');
      return 'Rp0';
    }
    
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(numPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
      ),
      body: _buildOrderList(),
    );
  }

  Widget _buildOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Orders')
          .orderBy('createdAt', descending: true) // Show newest first
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) => _buildOrderCard(
            context,
            snapshot.data!.docs[index],
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, DocumentSnapshot orderDoc) {
    final orderData = orderDoc.data() as Map<String, dynamic>;
    final userId = orderData['userId'] as String;
    final timestamp = DateTime.parse(orderData['createdAt']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: _buildCustomerInfo(userId),
        subtitle: _buildOrderSummary(orderData, timestamp),
        children: [
          _buildOrderDetails(context, orderDoc, orderData),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = userData['FirstName'] ?? '';
        final lastName = userData['LastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelanggan: $fullName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Email: ${userData['Email'] ?? ''}'),
          ],
        );
      },
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> orderData, DateTime timestamp) {
    final shippingAddress = orderData['shippingAddress'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status: ${orderData['statusPesanan']}'),
        Text('Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(timestamp)}'),
        Text('Alamat: ${shippingAddress['street']}, ${shippingAddress['city']}'),
      ],
    );
  }

  Widget _buildOrderDetails(
    BuildContext context,
    DocumentSnapshot orderDoc,
    Map<String, dynamic> orderData,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemsList(orderData['items'] as List),
          const Divider(),
          _buildTotalAmount(orderData['amount']),
          const SizedBox(height: 16),
          _buildStatusDropdown(context, orderDoc, orderData),
          if (orderData['statusHistory'] != null)
            _buildStatusHistory(orderData['statusHistory'] as List),
        ],
      ),
    );
  }

// Update _buildItemsList to handle price parsing
Widget _buildItemsList(List items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items.map((item) {
      final price = item['price'];
      final quantity = item['quantity'] as num;
      final total = price is num ? price * quantity : 0;
      
      return ListTile(
        title: Text(item['productName']),
        subtitle: Text(
          '${quantity}x @ ${_formatPrice(price)}',
        ),
        trailing: Text(_formatPrice(total)),
      );
    }).toList(),
  );
}

  Widget _buildTotalAmount(dynamic amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Total: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          _formatPrice(amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    DocumentSnapshot orderDoc,
    Map<String, dynamic> orderData,
  ) {
    return Row(
      children: [
        const Text('Ubah Status: '),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: orderData['statusPesanan'],
          items: _buildStatusItems(),
          onChanged: (newStatus) => _updateOrderStatus(
            orderDoc.id,
            newStatus!,
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildStatusItems() {
    return const [
      DropdownMenuItem(
        value: 'Sedang Di Proses',
        child: Text('Sedang Di Proses'),
      ),
      DropdownMenuItem(
        value: 'Sedang Di Kemas',
        child: Text('Sedang Di Kemas'),
      ),
      DropdownMenuItem(
        value: 'Dalam Perjalanan',
        child: Text('Dalam Perjalanan'),
      ),
      // DropdownMenuItem(
      //   value: 'Selesai',
      //   child: Text('Selesai'),
      // ),
    ];
  }

Widget _buildStatusHistory(List history) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Riwayat Status:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(history.length, (index) {
            final item = history[index];
            final timestamp = DateTime.parse(item['timestamp']);
            final isFirst = index == 0;
            final isLast = index == history.length - 1;

            return TimelineTile(
              isFirst: isFirst,
              isLast: isLast,
              beforeLineStyle: const LineStyle(color: Colors.blue),
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: Colors.blue,
                iconStyle: IconStyle(
                  iconData: Icons.circle,
                  color: Colors.white,
                ),
              ),
              endChild: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['status'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Updated by: ${item['updatedBy']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ],
  );
}

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .update({
        'statusPesanan': newStatus,
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus,
            'timestamp': DateTime.now().toIso8601String(),
            'updatedBy': 'admin', // Consider getting actual admin ID
          }
        ])
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }
}