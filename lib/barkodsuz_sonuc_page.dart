import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'diger_magazalar_page.dart';
import 'urun_kodu_sec_page.dart';

class BarkodsuzSonucPage extends StatefulWidget {
  final String urunAdi;
  final String rol;
  final String magaza;
  final String urunKodu;

  const BarkodsuzSonucPage({
    super.key,
    required this.urunAdi,
    required this.rol,
    required this.magaza,
    required this.urunKodu,
  });

  @override
  State<BarkodsuzSonucPage> createState() => _BarkodsuzSonucPageState();
}

class _BarkodsuzSonucPageState extends State<BarkodsuzSonucPage> {
  Map<String, dynamic>? urun;
  List<Map<String, dynamic>> stoklar = [];
  String rafNo = "-";
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    urunuGetir();
  }

  Map<String, List<Map<String, dynamic>>> grupluStoklar() {
    final sonuc = <String, List<Map<String, dynamic>>>{};

    for (final s in stoklar) {
      final renkKey = "${s['Renk Kodu']}|${s['Renk Açıklaması']}";

      sonuc.putIfAbsent(renkKey, () => []);

      if (widget.rol == "admin") {
        final index = sonuc[renkKey]!.indexWhere(
          (e) => e["Beden"] == s["Beden"],
        );

        if (index == -1) {
          sonuc[renkKey]!.add({"Beden": s["Beden"], "Envanter": s["Envanter"]});
        } else {
          final mevcut =
              int.tryParse(sonuc[renkKey]![index]["Envanter"].toString()) ?? 0;

          final yeni = int.tryParse(s["Envanter"].toString()) ?? 0;

          sonuc[renkKey]![index]["Envanter"] = mevcut + yeni;
        }
      } else {
        sonuc[renkKey]!.add(s);
      }
    }

    return sonuc;
  }

  Future<void> urunuGetir() async {
    final sonuc = await SupabaseService.client
        .from("stoklar")
        .select()
        .eq("Ürün Kodu", widget.urunKodu);

    print(sonuc);

    if (sonuc.isEmpty) {
      setState(() {
        yukleniyor = false;
      });
      return;
    }

    urun = sonuc.first;
    stoklar = List<Map<String, dynamic>>.from(
      sonuc.where((e) => e["Mağaza Adı"] == widget.magaza),
    );

    String bulunanRaf = "--";

    final rafSorgu = await SupabaseService.client
        .from("raflar")
        .select()
        .eq("urun_adi", widget.urunAdi)
        .eq("magaza_adi", widget.magaza);

    if (rafSorgu.isNotEmpty) {
      if (urun!["UH_KATEGORİ"] == "DENİM") {
        final yikama = urun!["YIKAMA Açıklama"] ?? "";

        final kayit = rafSorgu.firstWhere(
          (r) => r["yikama"] == yikama,
          orElse: () => <String, dynamic>{},
        );

        if (kayit.isNotEmpty) {
          bulunanRaf = kayit["raf_no"] ?? "--";
        } else {
          bulunanRaf = rafSorgu.first["raf_no"] ?? "--";
        }
      } else {
        bulunanRaf = rafSorgu.first["raf_no"] ?? "--";
      }
    }

    rafNo = bulunanRaf;

    setState(() {
      yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürün Sonucu")),
      body: yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urun?["Ürün Adı"] ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text("Ürün Kodu: ${urun?["Ürün Kodu"] ?? "-"}"),
                  Text("Kategori: ${urun?["UH_KATEGORİ"] ?? "-"}"),

                  if ((urun?["YIKAMA Açıklama"] ?? "").toString().isNotEmpty)
                    Text("Yıkama: ${urun?["YIKAMA Açıklama"]}"),

                  const SizedBox(height: 20),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text("Raf Bilgisi"),
                      subtitle: Text(rafNo),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Mağaza Stokları",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: grupluStoklar().entries.map((entry) {
                        final beden = entry.key;
                        final liste = entry.value;

                        final envanter = liste.fold<int>(0, (toplam, e) {
                          final adet =
                              int.tryParse(e["Envanter"].toString()) ?? 0;
                          return toplam + adet;
                        });

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                beden,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ...liste.map((s) {
                              return ListTile(
                                title: Text("Beden: ${s["Beden"]}"),
                                trailing: Text("${s["Envanter"]} Adet"),
                                onTap: () {
                                  final envanter =
                                      int.tryParse(s["Envanter"].toString()) ??
                                      0;

                                  if (envanter == 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DigerMagazalarPage(
                                          urunKodu: s["Ürün Kodu"].toString(),
                                          renkKodu: s["Renk Kodu"].toString(),
                                          renk: s["Renk Açıklaması"].toString(),
                                          beden: s["Beden"].toString(),
                                          mevcutMagaza: widget.magaza,
                                          kategori:
                                              urun?["ÜH_KATEGORİ"]
                                                  ?.toString() ??
                                              "",
                                          yikama:
                                              urun?["Açıklama"]?.toString() ??
                                              "",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }),

                            const Divider(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
