class TransactionStatus {
  final String orderId;
  final String status;
  final String transactionId;
  final DateTime timestamp;

  TransactionStatus({
    required this.orderId,
    required this.status,
    required this.transactionId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'status': status,
    'transactionId': transactionId,
    'timestamp': timestamp.toIso8601String(),
  };
}
