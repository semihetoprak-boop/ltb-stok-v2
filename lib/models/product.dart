class Product {
  final String productCode;
  final String barcode;
  final String productName;
  final String colorCode;
  final String colorName;
  final String size;
  final int stock;
  final String store;
  final String category;
  final String? wash;
  final String? shelf;

  const Product({
    required this.productCode,
    required this.barcode,
    required this.productName,
    required this.colorCode,
    required this.colorName,
    required this.size,
    required this.stock,
    required this.store,
    required this.category,
    this.wash,
    this.shelf,
  });
}
