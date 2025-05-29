class BookingServiceModel {
  final String? id;
  final String? bookingId;
  final String? serviceId;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingServiceModel({
    this.id,
    this.bookingId,
    this.serviceId,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingServiceModel.fromMap(Map<String, dynamic> map) {
    return BookingServiceModel(
      id: map['id'] as String?,
      bookingId: map['booking_id'] as String?,
      serviceId: map['service_id'] as String?,
      price: map['price'] != null ? double.tryParse(map['price'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'service_id': serviceId,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
