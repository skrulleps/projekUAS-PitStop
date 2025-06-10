import 'dart:convert';
import 'dart:typed_data';

class CustomerModel {
  final String? id;
  final String? usersId;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? photos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.usersId,
    this.fullName,
    this.phone,
    this.address,
    this.photos,
    this.createdAt,
    this.updatedAt,
  });

  Uint8List? get photosBytes {
    if (photos == null) return null;
    try {
      return base64Decode(photos!);
    } catch (e) {
      return null;
    }
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String?,
      usersId: map['users_id'] as String?,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      photos: map['photos'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users_id': usersId,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'photos': photos,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
