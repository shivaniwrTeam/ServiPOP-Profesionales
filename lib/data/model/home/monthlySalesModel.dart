class SalesModel {
  final String? year;
  final String? month;
  final String? totalAmount;
  final String? week;

  SalesModel({
    this.year,
    this.month,
    this.totalAmount,
    this.week
  });

  SalesModel.fromJson(Map<String, dynamic> json)
      : year = json['year'] as String?,
        month = json['month'] as String? ,
        totalAmount = json['total_amount'] as String?,
        week = json['week'] as String? ;

  Map<String, dynamic> toJson() =>
      {'year': year, 'month': month, 'total_amount': totalAmount, 'week': week};
}
