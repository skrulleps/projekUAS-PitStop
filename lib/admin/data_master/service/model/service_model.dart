class ServiceModel {
  final String? id;
  final String? serviceName;
  final String? description;
  final String? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    this.id,
    this.serviceName,
    this.description,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as String?,
      serviceName: map['service_name'] as String?,
      description: map['description'] as String?,
      price: map['price'] as String?,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_name': serviceName,
      'description': description,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
