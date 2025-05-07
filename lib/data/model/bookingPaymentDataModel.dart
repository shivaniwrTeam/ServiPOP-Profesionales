class BookingPaymentDataModel {
  final String id;
  final String providerId;
  final String partnerName;
  final String orderId;
  final String message;
  final String paymentRequestId;
  final String commissionPercentage;
  final String type;
  final String date;
  final String time;
  final String amount;
  final String totalAmount;
  final String commissionAmount;

  BookingPaymentDataModel({
    required this.id,
    required this.providerId,
    required this.partnerName,
    required this.orderId,
    required this.message,
    required this.paymentRequestId,
    required this.commissionPercentage,
    required this.type,
    required this.date,
    required this.time,
    required this.amount,
    required this.totalAmount,
    required this.commissionAmount,
  });

  BookingPaymentDataModel copyWith({
    String? id,
    String? providerId,
    String? partnerName,
    String? orderId,
    String? message,
    String? paymentRequestId,
    String? commissionPercentage,
    String? type,
    String? date,
    String? time,
    String? amount,
    String? totalAmount,
    String? commissionAmount,
  }) =>
      BookingPaymentDataModel(
        id: id ?? this.id,
        providerId: providerId ?? this.providerId,
        partnerName: partnerName ?? this.partnerName,
        orderId: orderId ?? this.orderId,
        message: message ?? this.message,
        paymentRequestId: paymentRequestId ?? this.paymentRequestId,
        commissionPercentage: commissionPercentage ?? this.commissionPercentage,
        type: type ?? this.type,
        date: date ?? this.date,
        time: time ?? this.time,
        amount: amount ?? this.amount,
        totalAmount: totalAmount ?? this.totalAmount,
        commissionAmount: commissionAmount ?? this.commissionAmount,
      );

  factory BookingPaymentDataModel.fromJson(Map<String, dynamic> json) => BookingPaymentDataModel(
        id: json["id"] ??"0",
        providerId: json["provider_id"] ?? "",
        partnerName: json["partner_name"] ?? "",
        orderId: json["order_id"] ?? "",
        message: json["message"] ?? "",
        paymentRequestId: json["payment_request_id"] ?? "",
        commissionPercentage: json["commission_percentage"] ?? "0",
        type: json["type"] ?? "",
        date: json["date"] ?? "",
        time: json["original_time"] ?? "",
        amount: json["amount"] ?? "0",
        totalAmount: json["total_amount"] ?? "0",
        commissionAmount: json["commission_amount"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "provider_id": providerId,
        "partner_name": partnerName,
        "order_id": orderId,
        "message": message,
        "payment_request_id": paymentRequestId,
        "commission_percentage": commissionPercentage,
        "type": type,
        "date": date,
        "original_time": time,
        "amount": amount,
        "total_amount": totalAmount,
        "commission_amount": commissionAmount,
      };
}
