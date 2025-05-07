class PromocodeModel {
  String? id;
  String? partnerId;
  String? partnerName;
  String? promoCode;
  String? message;
  String? startDate;
  String? endDate;
  String? noOfUsers;
  String? minimumOrderAmount;
  String? discount;
  String? discountType;
  String? maxDiscountAmount;
  String? repeatUsage;
  String? noOfRepeatUsage;
  String? image;
  String? status;
  String? createdAt;
  String? totalUsedNumber;

  PromocodeModel({
    this.id,
    this.partnerId,
    this.partnerName,
    this.promoCode,
    this.message,
    this.startDate,
    this.endDate,
    this.noOfUsers,
    this.minimumOrderAmount,
    this.discount,
    this.discountType,
    this.maxDiscountAmount,
    this.repeatUsage,
    this.noOfRepeatUsage,
    this.image,
    this.status,
    this.totalUsedNumber,
    this.createdAt,
  });

  PromocodeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    promoCode = json['promo_code'];
    partnerId = json['partner_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    minimumOrderAmount = json['minimum_order_amount'];
    discount = json['discount'];
    discountType = json['discount_type'];
    maxDiscountAmount = json['max_discount_amount'];
    status = json['status'];
    message = json['message'];
    image = json['image'];
    noOfUsers = json['no_of_users'];
    totalUsedNumber = (json['total_used_number'] ?? 0).toString();
    repeatUsage = json['repeat_usage'];
    partnerName = json['partner_name'];
    noOfRepeatUsage = json['no_of_repeat_usage'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['partner_id'] = partnerId;
    data['partner_name'] = partnerName;
    data['promo_code'] = promoCode;
    data['message'] = message;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['no_of_users'] = noOfUsers;
    data['minimum_order_amount'] = minimumOrderAmount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['max_discount_amount'] = maxDiscountAmount;
    data['repeat_usage'] = repeatUsage;
    data['no_of_repeat_usage'] = noOfRepeatUsage;
    data['image'] = image;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['total_used_number'] = totalUsedNumber;
    return data;
  }

  @override
  String toString() {
    return 'PromocodeModel(id: $id, partnerId: $partnerId, partnerName: $partnerName, promoCode: $promoCode, message: $message, startDate: $startDate, endDate: $endDate, noOfUsers: $noOfUsers, minimumOrderAmount: $minimumOrderAmount, discount: $discount, discountType: $discountType, maxDiscountAmount: $maxDiscountAmount, repeatUsage: $repeatUsage, noOfRepeatUsage: $noOfRepeatUsage, image: $image, status: $status, createdAt: $createdAt)';
  }
}
