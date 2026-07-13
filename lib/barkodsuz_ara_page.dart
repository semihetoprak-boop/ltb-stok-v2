import 'package:flutter/material.dart';
import 'urun_kodu_sec_page.dart';

class BarkodsuzAraPage extends StatefulWidget {
  final String magaza;
  final String rol;

  const BarkodsuzAraPage({super.key, required this.magaza, required this.rol});

  @override
  State<BarkodsuzAraPage> createState() => _BarkodsuzAraPageState();
}

class _BarkodsuzAraPageState extends State<BarkodsuzAraPage> {
  final TextEditingController urunController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Barkodsuz Ürün Ara")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: urunController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Ürün Adı",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final urun = urunController.text.trim();

                  if (urun.isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UrunKoduSecPage(
                        urunAdi: urunController.text.trim(),
                        rol: widget.rol,
                        magaza: widget.magaza,
                      ),
                    ),
                  );
                },
                child: const Text("ARA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
