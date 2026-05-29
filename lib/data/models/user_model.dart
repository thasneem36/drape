class Address {
  final String label, line1, line2;
  final bool isDefault;
  const Address(this.label, this.line1, this.line2,
      {this.isDefault = false});

  factory Address.fromMap(Map<String, dynamic> d) => Address(
        (d['label'] as String?) ?? '',
        (d['line1'] as String?) ?? '',
        (d['line2'] as String?) ?? '',
        isDefault: (d['isDefault'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
        'label': label,
        'line1': line1,
        'line2': line2,
        'isDefault': isDefault,
      };
}

class Payment {
  final String label, detail, brand;
  const Payment(this.label, this.detail, this.brand);

  factory Payment.fromMap(Map<String, dynamic> d) => Payment(
        (d['label'] as String?) ?? '',
        (d['detail'] as String?) ?? '',
        (d['brand'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'label': label,
        'detail': detail,
        'brand': brand,
      };
}
