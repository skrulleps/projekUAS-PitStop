class BookingModel {
  final String? id;
  final String? usersId;
  final String? mechanicsId;
  final String? servicesId;
  final DateTime? bookingsDate;
  final String? bookingsTime; // time without time zone as String
  final String? status; // Pending, Confirmed, On Progress, Done, Cancelled
  final String? notes;
  final double? totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    this.id,
    this.usersId,
    this.mechanicsId,
    this.servicesId,
    this.bookingsDate,
    this.bookingsTime,
    this.status,
    this.notes,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String?,
      usersId: map['users_id'] as String?,
      mechanicsId: map['mechanics_id'] as String?,
      servicesId: map['services_id'] as String?,
      bookingsDate: map['bookings_date'] != null ? DateTime.parse(map['bookings_date']) : null,
      bookingsTime: map['bookings_time'] as String?,
      status: map['status'] as String?,
      notes: map['notes'] as String?,
      totalPrice: map['total_price'] != null ? double.tryParse(map['total_price'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users_id': usersId,
      'mechanics_id': mechanicsId,
      'services_id': servicesId,
      'bookings_date': bookingsDate?.toIso8601String(),
      'bookings_time': bookingsTime,
      'status': status,
      'notes': notes,
      'total_price': totalPrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
