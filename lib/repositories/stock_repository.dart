import '../models/product.dart';

abstract class StockRepository {
  Future<Product?> getByBarcode(String barcode);

  Future<List<Product>> getByProductCode(String productCode);

  Future<List<Product>> search({
    required String text,
    required String store,
    required String role,
  });
  Future<List<Product>> getOtherStores({
    required String productCode,
    required String colorCode,
    required String size,
    required String currentStore,
    required String category,
    required String wash,
  });

  Future<void> updateStock({required String productCode, required int stock});
}
