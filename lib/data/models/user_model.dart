class Address {
  final String label, line1, line2;
  final bool isDefault;
  const Address(this.label, this.line1, this.line2, {this.isDefault = false});
}

class Payment {
  final String label, detail, brand;
  const Payment(this.label, this.detail, this.brand);
}
