import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'barkodsuz_sonuc_page.dart';

class UrunKoduSecPage extends StatefulWidget {
  final String urunAdi;
  final String rol;
  final String magaza;

  const UrunKoduSecPage({
    super.key,
    required this.urunAdi,
    required this.rol,
    required this.magaza,
  });

  @override
  State<UrunKoduSecPage> createState() => _UrunKoduSecPageState();
}

class _UrunKoduSecPageState extends State<UrunKoduSecPage> {
  List<Map<String, dynamic>> urunler = [];
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    urunleriGetir();
  }

  Future<void> urunleriGetir() async {
    final sonuc = await SupabaseService.client
        .from("stoklar")
        .select()
        .eq("Ürün Adı", widget.urunAdi);

    setState(() {
      final map = <String, Map<String, dynamic>>{};

      for (final u in sonuc) {
        map.putIfAbsent(
          u["Ürün Kodu"].toString(),
          () => Map<String, dynamic>.from(u),
        );
      }

      urunler = map.values.toList();
      yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (yukleniyor) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Ürün Kodu Seç")),
      body: ListView.builder(
        itemCount: urunler.length,
        itemBuilder: (context, index) {
          final urun = urunler[index];

          return ListTile(
            title: Text(urun["Ürün Kodu"].toString()),
            subtitle: null,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BarkodsuzSonucPage(
                    urunAdi: widget.urunAdi,
                    urunKodu: urun["Ürün Kodu"].toString(),
                    rol: widget.rol,
                    magaza: widget.magaza,
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
