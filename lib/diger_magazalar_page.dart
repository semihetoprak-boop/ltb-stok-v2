import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'services/supabase_stock_repository.dart';
import 'models/product.dart';

class DigerMagazalarPage extends StatelessWidget {
  final String urunKodu;
  final String renkKodu;
  final String renk;
  final String beden;
  final String mevcutMagaza;
  final String kategori;
  final String yikama;

  final _repository = SupabaseStockRepository();

  DigerMagazalarPage({
    super.key,
    required this.urunKodu,
    required this.renkKodu,
    required this.renk,
    required this.beden,
    required this.mevcutMagaza,
    required this.kategori,
    required this.yikama,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diğer Mağazalar")),
      body: FutureBuilder<List<Product>>(
        future: _repository.getOtherStores(
          productCode: urunKodu,
          colorCode: renkKodu,
          size: beden,
          currentStore: mevcutMagaza,
          category: kategori,
          wash: yikama,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final liste = snapshot.data ?? <Product>[];

          if (liste.isEmpty) {
            return const Center(
              child: Text("Diğer mağazalarda stok bulunamadı."),
            );
          }

          return ListView.builder(
            itemCount: liste.length,
            itemBuilder: (context, index) {
              final s = liste[index];

              return ListTile(
                leading: const Icon(Icons.store),
                title: Text(s.store),
                trailing: Text(
                  s.stock.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
