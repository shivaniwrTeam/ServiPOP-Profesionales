class BookingCountingModel {
  final int? todayBookings;
  final int? tommorrowBookings;
  final int? upcomingBookings;

  BookingCountingModel({
    this.todayBookings,
    this.tommorrowBookings,
    this.upcomingBookings,
  });

  BookingCountingModel.fromJson(Map<String, dynamic> json)
      : todayBookings = json['today_bookings'] as int?,
        tommorrowBookings = json['tommorrow_bookings'] as int?,
        upcomingBookings = json['upcoming_bookings'] as int?;

  Map<String, dynamic> toJson() => {
        'today_bookings': todayBookings,
        'tommorrow_bookings': tommorrowBookings,
        'upcoming_bookings': upcomingBookings
      };
}
