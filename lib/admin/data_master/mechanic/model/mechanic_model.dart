class MechanicModel {
  final String? id;
  final String? fullName;
  final String? phone;
  final String? spesialisasi;
  final String? status;

  MechanicModel({
    this.id,
    this.fullName,
    this.phone,
    this.spesialisasi,
    this.status,
  });

  factory MechanicModel.fromMap(Map<String, dynamic> map) {
    return MechanicModel(
      id: map['id'] as String?,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      spesialisasi: map['spesialisasi'] as String?,
      status: map['status'] as String?,
    );
  }
}
