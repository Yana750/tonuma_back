class Address {
  final int id;
  final String address;
  final String deliveryType;
  final bool isDefault;

  Address({
    required this.id,
    required this.address,
    required this.deliveryType,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      address: json['address'],
      deliveryType: json['delivery_type'],
      isDefault: json['is_default'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'delivery_type': deliveryType,
      'is_default': isDefault,
    };
  }
}
