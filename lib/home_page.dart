import 'package:flutter/material.dart';
import 'barkod_page.dart';
import 'login_page.dart';
import 'raf_yonetimi_page.dart';
import 'barkodsuz_ara_page.dart';

class HomePage extends StatelessWidget {
  final String kullanici;
  final String rol;
  final String magaza;

  const HomePage({
    super.key,
    required this.kullanici,
    required this.rol,
    required this.magaza,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LTB STOK"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Hoşgeldin $kullanici",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text("Mağaza : $magaza", style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BarkodPage(rol: rol, magaza: magaza),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Barkod Oku"),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BarkodsuzAraPage(magaza: magaza, rol: rol),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("Barkodsuz Ürün Ara"),
            ),

            const SizedBox(height: 15),

            if (rol == "mudur")
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.inventory_2),
                    label: const Text("📦 Raf Yönetimi"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RafYonetimiPage(magaza: magaza, rol: rol),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const Spacer(),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Çıkış Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
