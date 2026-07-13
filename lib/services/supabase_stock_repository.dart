import '../models/product.dart';
import '../repositories/stock_repository.dart';
import '../supabase_service.dart';

class SupabaseStockRepository implements StockRepository {
  Product _mapProduct(Map<String, dynamic> item) {
    return Product(
      productCode: item['Ürün Kodu'].toString(),
      barcode: item['Barkod'].toString(),
      productName: item['Ürün Adı'].toString(),
      colorCode: (item['Renk Kodu'] ?? '').toString(),
      colorName: (item['Renk Açıklaması'] ?? '').toString(),
      size: (item['Beden'] ?? '').toString(),
      stock: int.tryParse(item['Envanter'].toString()) ?? 0,
      store: (item['Mağaza Adı'] ?? '').toString(),
      category: (item['UH_KATEGORİ'] ?? '').toString(),
      wash: item['YIKAMA Açıklama']?.toString(),
      shelf: null,
    );
  }

  List<Product> _mapProducts(List<dynamic> items) {
    return items
        .map((item) => _mapProduct(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  bool _isDenim(String category) {
    final normalized = category
        .trim()
        .toUpperCase()
        .replaceAll('İ', 'I');
    return normalized == 'DENIM';
  }

  @override
  Future<Product?> getByBarcode(String barcode) async {
    final sonuc = await SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Barkod', barcode)
        .limit(1);

    if (sonuc.isEmpty) return null;
    return _mapProduct(Map<String, dynamic>.from(sonuc.first));
  }

  @override
  Future<List<Product>> getByProductCode(String productCode) async {
    final sonuc = await SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Ürün Kodu', productCode);

    return _mapProducts(sonuc);
  }

  @override
  Future<List<Product>> getByProductName(String productName) async {
    final sonuc = await SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Ürün Adı', productName);

    return _mapProducts(sonuc);
  }

  @override
  Future<List<Product>> search({
    required String text,
    required String store,
    required String role,
  }) async {
    final queryText = text.trim();
    if (queryText.isEmpty) return [];

    final byName = await SupabaseService.client
        .from('stoklar')
        .select()
        .ilike('Ürün Adı', '%$queryText%');

    final byCode = await SupabaseService.client
        .from('stoklar')
        .select()
        .ilike('Ürün Kodu', '%$queryText%');

    final merged = <String, Map<String, dynamic>>{};

    for (final raw in [...byName, ...byCode]) {
      final item = Map<String, dynamic>.from(raw);
      if (role != 'admin' &&
          (item['Mağaza Adı'] ?? '').toString() != store) {
        continue;
      }

      final key = [
        item['Ürün Kodu'],
        item['Barkod'],
        item['Renk Kodu'],
        item['Beden'],
        item['Mağaza Adı'],
      ].join('|');

      merged[key] = item;
    }

    return _mapProducts(merged.values.toList());
  }

  @override
  Future<List<Product>> getOtherStores({
    required String productCode,
    required String colorCode,
    required String size,
    required String currentStore,
    required String category,
    required String wash,
  }) async {
    var query = SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Ürün Kodu', productCode)
        .eq('Renk Kodu', colorCode)
        .eq('Beden', size)
        .neq('Mağaza Adı', currentStore)
        .gt('Envanter', 0);

    if (_isDenim(category)) {
      query = query.eq('YIKAMA Açıklama', wash);
    }

    final sonuc = await query;
    return _mapProducts(sonuc);
  }
}
