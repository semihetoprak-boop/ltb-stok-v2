import 'package:flutter/material.dart';
import 'supabase_service.dart';

class DigerMagazalarPage extends StatelessWidget {
  final String urunKodu;
  final String renkKodu;
  final String renk;
  final String beden;
  final String mevcutMagaza;
  final String kategori;
  final String yikama;

  const DigerMagazalarPage({
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
      body: FutureBuilder(
        future: () async {
          var query = SupabaseService.client
              .from('stoklar')
              .select()
              .eq('Ürün Kodu', urunKodu)
              .eq('Renk Kodu', renkKodu)
              .eq('Beden', beden)
              .neq('Mağaza Adı', mevcutMagaza)
              .gt('Envanter', 0);

          if (kategori.toUpperCase() == 'DENİM') {
            query = query.eq('YIKAMA Açıklama', yikama);
          }

          return await query;
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final liste = snapshot.data as List? ?? [];

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
                title: Text(s["Mağaza Adı"].toString()),
                trailing: Text(
                  s["Envanter"].toString(),
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
