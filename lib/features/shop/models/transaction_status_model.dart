import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionStatus {
  final String orderId;
  final String status;
  final String transactionId;
  final DateTime timestamp;
  final String paymentMethod;
  // final String virtualAccount;

  TransactionStatus({
    required this.orderId,
    required this.status,
    required this.transactionId,
    required this.timestamp,
    this.paymentMethod = '',
    // this.virtualAccount = '',
  });

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'status': status,
    'transactionId': transactionId,
    'timestamp': timestamp.toIso8601String(),
    'paymentMethod': paymentMethod,
    // 'virtualAccount': virtualAccount,
  };

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      transactionId: json['transactionId'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      paymentMethod: json['paymentMethod'] ?? '',
      // virtualAccount: json['virtualAccount'] ?? '',
    );
  }

  bool get isSuccess => status == 'success' || status == 'settlement';
}
