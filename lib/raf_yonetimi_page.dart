import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class RafYonetimiPage extends StatefulWidget {
  final String magaza;
  final String rol;

  const RafYonetimiPage({super.key, required this.magaza, required this.rol});

  @override
  State<RafYonetimiPage> createState() => _RafYonetimiPageState();
}

final TextEditingController aramaController = TextEditingController();

String aranan = "";

class _RafYonetimiPageState extends State<RafYonetimiPage> {
  Future<List<dynamic>> raflariGetir() async {
    return await SupabaseService.client
        .from('raflar')
        .select()
        .eq('magaza_adi', widget.magaza)
        .order('urun_adi');
  }

  Future<void> rafDuzenle(Map raf) async {
    final controller = TextEditingController(text: raf["raf_no"]);

    final yeniRaf = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Raf Düzenle"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Yeni Raf No"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );

    if (yeniRaf == null || yeniRaf.isEmpty) return;

    await SupabaseService.client
        .from("raflar")
        .update({"raf_no": yeniRaf})
        .eq("id", raf["id"]);

    setState(() {});
  }

  Future<void> rafSil(Map raf) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Raf Sil"),
          content: Text(
            "${raf["urun_adi"]} ürününün rafını silmek istiyor musunuz?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hayır"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );

    if (onay != true) return;

    await SupabaseService.client.from("raflar").delete().eq("id", raf["id"]);

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Raf silindi.")));
    }
  }

  Future<void> yeniRafEkle() async {
    final urunController = TextEditingController();
    final yikamaController = TextEditingController();
    final rafController = TextEditingController();

    final sonuc = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Raf Ekle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urunController,
                  decoration: const InputDecoration(labelText: "Ürün Adı"),
                ),
                TextField(
                  controller: yikamaController,
                  decoration: const InputDecoration(labelText: "Yıkama"),
                ),
                TextField(
                  controller: rafController,
                  decoration: const InputDecoration(labelText: "Raf No"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );

    if (sonuc != true) return;

    await SupabaseService.client.from("raflar").insert({
      "urun_adi": urunController.text.trim().toUpperCase(),
      "yikama": yikamaController.text.trim().toUpperCase(),
      "raf_no": rafController.text.trim().toUpperCase(),
      "magaza_adi": widget.magaza,
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Raf silindi.")));
    }
  }

  Future<void> excelIceriAktar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) return;

    final bytes = result.files.single.bytes;
    if (bytes == null) return;

    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables["Raflar"];

    if (sheet == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Raflar sayfası bulunamadı.")),
        );
      }
      return;
    }

    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);

      final urun = row[0]?.value?.toString().trim().toUpperCase() ?? "";

      final yikama = row[1]?.value?.toString().trim().toUpperCase() ?? "";

      final rafNo = row[2]?.value?.toString().trim().toUpperCase() ?? "";

      if (urun.isEmpty) continue;

      await SupabaseService.client.from("raflar").upsert({
        "urun_adi": urun,
        "yikama": yikama,
        "raf_no": rafNo,
        "magaza_adi": widget.magaza,
      }, onConflict: "magaza_adi,urun_adi,yikama");
    }

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Excel başarıyla içe aktarıldı.")),
      );
    }
  }

  Future<void> excelDisariAktar() async {
    final veriler = await SupabaseService.client
        .from("raflar")
        .select()
        .eq("magaza_adi", widget.magaza)
        .order("urun_adi");

    var excel = Excel.createExcel();
    excel.delete('Sheet1');
    Sheet sheet = excel["Raflar"];

    sheet.appendRow([
      TextCellValue("Ürün Adı"),
      TextCellValue("Yıkama"),
      TextCellValue("Raf No"),
    ]);

    for (var raf in veriler) {
      sheet.appendRow([
        TextCellValue(raf["urun_adi"] ?? ""),
        TextCellValue(raf["yikama"] ?? ""),
        TextCellValue(raf["raf_no"] ?? ""),
      ]);
    }

    final bytes = excel.encode();

    if (bytes == null) return;

    if (kIsWeb) {
      final blob = html.Blob([bytes]);

      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..download = "Raflar_${widget.magaza}.xlsx"
        ..click();

      html.Url.revokeObjectUrl(url);

      return;
    } else {
      final directory = await getApplicationDocumentsDirectory();

      final file = File("${directory.path}/Raflar_${widget.magaza}.xlsx");

      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raf Yönetimi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: excelIceriAktar,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: excelDisariAktar,
          ),
        ],
      ),
      body: FutureBuilder(
        future: raflariGetir(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final liste = snapshot.data as List;
          final filtreliListe = liste.where((e) {
            final urun = e["urun_adi"].toString().toLowerCase();
            final raf = e["raf_no"].toString().toLowerCase();

            return urun.contains(aranan.toLowerCase()) ||
                raf.contains(aranan.toLowerCase());
          }).toList();

          if (liste.isEmpty) {
            return const Center(
              child: Text("Bu mağazada raf kaydı bulunmuyor."),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: aramaController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Ürün veya raf ara...",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      aranan = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Yeni Raf Ekle"),
                    onPressed: () => yeniRafEkle(),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filtreliListe.length,
                  itemBuilder: (context, index) {
                    final raf = filtreliListe[index];

                    return ListTile(
                      title: Text(raf["urun_adi"]),
                      subtitle: raf["yikama"] == "EMPTY"
                          ? null
                          : Text("Yıkama : ${raf["yikama"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            raf["raf_no"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => rafDuzenle(raf),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => rafSil(raf),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
