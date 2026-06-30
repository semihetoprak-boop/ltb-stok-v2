import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'supabase_service.dart';
import 'diger_magazalar_page.dart';

class BarkodPage extends StatefulWidget {
  final String rol;
  final String magaza;

  const BarkodPage({super.key, required this.rol, required this.magaza});

  @override
  State<BarkodPage> createState() => _BarkodPageState();
}

class _BarkodPageState extends State<BarkodPage> {
  final MobileScannerController controller = MobileScannerController();

  String barkod = " ";

  Map<String, dynamic>? urun;

  List<Map<String, dynamic>> stoklar = [];
  String rafNo = "-";

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          sonuc[renkKey]![index]["Envanter"] =
              (sonuc[renkKey]![index]["Envanter"] ?? 0) + (s["Envanter"] ?? 0);
        }
      } else {
        sonuc[renkKey]!.add(s);
      }
    }

    return sonuc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Barkod Oku")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                if (capture.barcodes.isEmpty) return;

                final barcode = capture.barcodes.first;

                if (barcode.rawValue == null) return;

                final code = barcode.rawValue!;

                final sonuc = await SupabaseService.client
                    .from('stoklar')
                    .select()
                    .eq('Barkod', code);

                if (sonuc.isEmpty) {
                  return;
                }

                final urunKodu = sonuc.first['Ürün Kodu'];

                dynamic sorgu = SupabaseService.client
                    .from('stoklar')
                    .select()
                    .eq('Ürün Kodu', urunKodu);

                if (widget.rol != "admin") {
                  sorgu = sorgu.eq("Mağaza Adı", widget.magaza);
                }

                final tumStoklar = await sorgu;
                String bulunanRaf = "-";
                final rafSorgu = await SupabaseService.client
                    .from('raflar')
                    .select()
                    .eq('urun_adi', sonuc.first['Ürün Adı'])
                    .eq('magaza_adi', widget.magaza);

                if (rafSorgu.isNotEmpty) {
                  if (sonuc.first['UH_KATEGORİ'] == 'DENIM') {
                    final yikama = sonuc.first['YIKAMA Açıklama'] ?? "";

                    final kayit = rafSorgu.firstWhere(
                      (r) => r['yikama'] == yikama,
                      orElse: () => <String, dynamic>{},
                    );

                    if (kayit.isNotEmpty) {
                      bulunanRaf = kayit['raf_no'] ?? "";
                    }
                  } else {
                    bulunanRaf = rafSorgu.first['raf_no'] ?? "";
                  }
                }

                try {
                  dynamic rafSorgu = SupabaseService.client
                      .from('raflar')
                      .select()
                      .eq('urun_adi', sonuc.first['Ürün Adı']);

                  if (sonuc.first['UH_KATEGORİ'] == 'DENİM') {
                    rafSorgu = rafSorgu.eq(
                      'yikama',
                      sonuc.first['YIKAMA Açıklama'] ?? 'EMPTY',
                    );
                  }

                  rafSorgu = rafSorgu.eq('magaza_adi', widget.magaza);

                  final rafSonuc = await rafSorgu.limit(1);

                  if (rafSonuc.isNotEmpty) {
                    bulunanRaf = rafSonuc.first['raf_no'] ?? "-";
                  }
                } catch (_) {}

                setState(() {
                  barkod = code;
                  urun = sonuc.first;
                  stoklar = List<Map<String, dynamic>>.from(tumStoklar);
                  rafNo = bulunanRaf;
                });
                controller.stop();
              },
            ),
          ),

          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade200,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Envanter Bilgisi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Barkod : $barkod",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Ürün : ${urun?['Ürün Adı'] ?? '-'}",

                      style: const TextStyle(fontSize: 20),
                    ),

                    const SizedBox(height: 15),

                    Text("Kategori : ${urun?['UH_KATEGORİ'] ?? '-'}"),

                    if ((urun?['UH_KATEGORİ'] ?? '') == 'DENIM')
                      Text("Yıkama : ${urun?['YIKAMA Açıklama'] ?? '-'}"),

                    const SizedBox(height: 15),

                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📍 RAF BİLGİSİ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              rafNo,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.rol == "admin" ||
                                widget.rol == "mudur") ...[
                              const SizedBox(height: 15),

                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final controller =
                                            TextEditingController(text: rafNo);

                                        final yeniRaf =
                                            await showDialog<String>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    "Raf Düzenle",
                                                  ),
                                                  content: TextField(
                                                    controller: controller,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: "Raf No",
                                                        ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        "Vazgeç",
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                          controller.text
                                                              .trim(),
                                                        );
                                                      },
                                                      child: const Text(
                                                        "Kaydet",
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                        if (yeniRaf == null || yeniRaf.isEmpty)
                                          return;
                                        final mevcut = await SupabaseService
                                            .client
                                            .from('raflar')
                                            .select()
                                            .eq('urun_adi', urun?['Ürün Adı'])
                                            .eq('magaza_adi', widget.magaza);

                                        if (mevcut.isEmpty) {
                                          await SupabaseService.client
                                              .from('raflar')
                                              .insert({
                                                'urun_adi': urun?['Ürün Adı'],
                                                'yikama':
                                                    urun?['UH_KATEGORİ'] ==
                                                        'DENIM'
                                                    ? (urun?['YIKAMA Açıklama'] ??
                                                          '')
                                                    : '',
                                                'magaza_adi': widget.magaza,
                                                'raf_no': yeniRaf,
                                              });
                                        } else {
                                          await SupabaseService.client
                                              .from('raflar')
                                              .update({'raf_no': yeniRaf})
                                              .eq('id', mevcut.first['id']);
                                        }

                                        setState(() {
                                          rafNo = yeniRaf;
                                        });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Raf güncellendi"),
                                          ),
                                        );
                                        // Bir sonraki adımda buraya kayıt kodunu ekleyeceğiz.
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text("Raf Düzenle"),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final onay = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Raf Sil"),
                                            content: const Text(
                                              "Bu raf bilgisini silmek istiyor musunuz?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text("İptal"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text("Sil"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (onay != true) return;

                                        var sorgu = SupabaseService.client
                                            .from('raflar')
                                            .delete()
                                            .eq('urun_adi', urun?['Ürün Adı'])
                                            .eq('magaza_adi', widget.magaza);

                                        if (urun?['UH_KATEGORİ'] == 'DENIM') {
                                          sorgu = sorgu.eq(
                                            'yikama',
                                            urun?['YIKAMA Açıklama'] ?? '',
                                          );
                                        }

                                        await sorgu;

                                        setState(() {
                                          rafNo = "-";
                                        });

                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Raf silindi."),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text("Raf Sil"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const SizedBox(height: 20),
                    ...grupluStoklar().entries.map((g) {
                      final renk = g.key.split('|');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${renk[0]} - ${renk[1]}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Divider(),

                              ...g.value.map(
                                (s) => InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DigerMagazalarPage(
                                          urunKodu:
                                              urun?['Ürün Kodu'].toString() ??
                                              "",
                                          renkKodu: renk[0],
                                          renk: renk[1],
                                          beden: s['Beden'].toString(),
                                          mevcutMagaza: widget.magaza,
                                          kategori:
                                              urun?['UH_KATEGORİ']
                                                  ?.toString() ??
                                              "",
                                          yikama:
                                              urun?['YIKAMA Açıklama']
                                                  ?.toString() ??
                                              "",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              s['Beden'].toString(),
                                              style: TextStyle(
                                                color: s['Envanter'] == 0
                                                    ? Colors.red
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          s['Envanter'].toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: s['Envanter'] == 0
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
