import '../models/product.dart';
import '../repositories/stock_repository.dart';
import '../supabase_service.dart';

class SupabaseStockRepository implements StockRepository {
  @override
  Future<Product?> getByBarcode(String barcode) async {
    final sonuc = await SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Barkod', barcode)
        .limit(1);

    if (sonuc.isEmpty) return null;

    final item = sonuc.first;

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

  @override
  Future<List<Product>> getByProductCode(String productCode) async {
    final sonuc = await SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Ürün Kodu', productCode);

    return sonuc.map<Product>((e) {
      return Product(
        productCode: e['Ürün Kodu'].toString(),
        barcode: e['Barkod'].toString(),
        productName: e['Ürün Adı'].toString(),
        colorCode: (e['Renk Kodu'] ?? '').toString(),
        colorName: (e['Renk Açıklaması'] ?? '').toString(),
        size: (e['Beden'] ?? '').toString(),
        stock: int.tryParse(e['Envanter'].toString()) ?? 0,
        store: (e['Mağaza Adı'] ?? '').toString(),
        category: (e['UH_KATEGORİ'] ?? '').toString(),
        wash: e['YIKAMA Açıklama']?.toString(),
        shelf: null,
      );
    }).toList();
  }

  Future<List<Product>> getByProductName(String productName) async {
    final sonuc = await SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Ürün Adı', productName);

    return sonuc.map<Product>((e) {
      return Product(
        productCode: e['Ürün Kodu'].toString(),
        barcode: e['Barkod'].toString(),
        productName: e['Ürün Adı'].toString(),
        colorCode: (e['Renk Kodu'] ?? '').toString(),
        colorName: (e['Renk Açıklaması'] ?? '').toString(),
        size: (e['Beden'] ?? '').toString(),
        stock: int.tryParse(e['Envanter'].toString()) ?? 0,
        store: (e['Mağaza Adı'] ?? '').toString(),
        category: (e['UH_KATEGORİ'] ?? '').toString(),
        wash: e['YIKAMA Açıklama']?.toString(),
        shelf: null,
      );
    }).toList();
  }

  Future<List<Product>> getOtherStores({
    required String productCode,
    required String colorCode,
    required String size,
    required String currentStore,
    required String category,
    required String? wash,
  }) async {
    var query = SupabaseService.client
        .from('stoklar')
        .select()
        .eq('Ürün Kodu', productCode)
        .eq('Renk Kodu', colorCode)
        .eq('Beden', size)
        .neq('Mağaza Adı', currentStore)
        .gt('Envanter', 0);

    if (category.toUpperCase() == 'DENİM') {
      query = query.eq('YIKAMA Açıklama', wash ?? '');
    }

    final sonuc = await query;

    return sonuc.map<Product>((e) {
      return Product(
        productCode: e['Ürün Kodu'].toString(),
        barcode: e['Barkod'].toString(),
        productName: e['Ürün Adı'].toString(),
        colorCode: (e['Renk Kodu'] ?? '').toString(),
        colorName: (e['Renk Açıklaması'] ?? '').toString(),
        size: (e['Beden'] ?? '').toString(),
        stock: int.tryParse(e['Envanter'].toString()) ?? 0,
        store: (e['Mağaza Adı'] ?? '').toString(),
        category: (e['UH_KATEGORİ'] ?? '').toString(),
        wash: e['YIKAMA Açıklama']?.toString(),
        shelf: null,
      );
    }).toList();
  }

  @override
  Future<List<Product>> search({
    required String text,
    required String store,
    required String role,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateStock({
    required String productCode,
    required int stock,
  }) async {
    throw UnimplementedError();
  }
}
