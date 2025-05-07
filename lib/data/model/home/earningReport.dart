class EarningReport {
  final String? adminCommission;
  final String? myIncome;
  final String? remainingIncome;
  final String? futureEarningFromBookings;

  EarningReport({
    this.adminCommission,
    this.myIncome,
    this.remainingIncome,
    this.futureEarningFromBookings,
  });

  EarningReport.fromJson(Map<String, dynamic> json)
      : adminCommission = json['admin_commission'] as String?,
        myIncome = json['my_income'] as String?,
        remainingIncome = json['remaining_income'] as String?,
        futureEarningFromBookings =
            (json['future_earning_from_bookings'] ?? "0").toString();

  Map<String, dynamic> toJson() => {
        'admin_commission': adminCommission,
        'my_income': myIncome,
        'remaining_income': remainingIncome,
        'future_earning_from_bookings': futureEarningFromBookings
      };
}
