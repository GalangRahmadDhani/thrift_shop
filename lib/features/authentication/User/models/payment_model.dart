class PaymentModel {
  final String orderId;
  final int grossAmount;
  final Map<String, dynamic> customerDetails;
  final List<Map<String, dynamic>> items;

  PaymentModel({
    required this.orderId,
    required this.grossAmount,
    required this.customerDetails,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'gross_amount': grossAmount,
      'customer_details': customerDetails,
      'items': items,
    };
  }
}
