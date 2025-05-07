class WithdrawalModel {
  WithdrawalModel({
    this.id,
    this.userId,
    this.partnerName,
    this.userType,
    this.paymentAddress,
    this.amount,
    this.remarks,
    this.status,
    this.createdAt,
    this.operations,
    this.accountNumber,
  });

  WithdrawalModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    partnerName = json['partner_name'];
    userType = json['user_type'];
    paymentAddress = json['payment_address'];
    amount = json['amount'];
    remarks = json['remarks'];
    status = json['status'];
    createdAt = json['created_at'];
    operations = json['operations'];
    accountNumber = json['account_number'];
  }
  String? id;
  String? userId;
  String? partnerName;
  String? userType;
  String? paymentAddress;
  String? amount;
  String? remarks;
  String? status;
  String? createdAt;
  String? operations;
  String? accountNumber;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['partner_name'] = partnerName;
    data['user_type'] = userType;
    data['payment_address'] = paymentAddress;
    data['amount'] = amount;
    data['remarks'] = remarks;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['operations'] = operations;
    data['account_number'] = accountNumber;
    return data;
  }
}
