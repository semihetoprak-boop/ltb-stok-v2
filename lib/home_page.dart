import 'package:flutter/material.dart';

import 'barkod_page.dart';
import 'login_page.dart';
import 'raf_yonetimi_page.dart';
import 'barkodsuz_ara_page.dart';
import 'services/auth_service.dart';
import 'admin_sifre_page.dart';
import 'services/nebim_api_services.dart';

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

  Future<void> _sifreDegistir(BuildContext context) async {
    final yeniSifreController = TextEditingController();
    final tekrarSifreController = TextEditingController();

    final sifreDegistir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Şifre Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yeniSifreController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: tekrarSifreController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre Tekrar',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Şifreyi Değiştir'),
            ),
          ],
        );
      },
    );

    if (sifreDegistir != true) {
      yeniSifreController.dispose();
      tekrarSifreController.dispose();
      return;
    }

    final yeniSifre = yeniSifreController.text;
    final tekrarSifre = tekrarSifreController.text;

    yeniSifreController.dispose();
    tekrarSifreController.dispose();

    if (!context.mounted) return;

    if (yeniSifre.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifre en az 8 karakter olmalıdır.')),
      );
      return;
    }

    if (yeniSifre != tekrarSifre) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Girilen şifreler birbiriyle eşleşmiyor.'),
        ),
      );
      return;
    }

    try {
      await AuthService.changePassword(yeniSifre);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreniz başarıyla değiştirildi.')),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre değiştirilirken bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LTB STOK'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hoşgeldin $kullanici',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Mağaza : $magaza', style: const TextStyle(fontSize: 18)),
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
              label: const Text('Barkod Oku'),
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
              label: const Text('Barkodsuz Ürün Ara'),
            ),
            const SizedBox(height: 15),
            if (rol == 'mudur')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('📦 Raf Yönetimi'),
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
            if (rol == "admin")
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text("Şifre Yönetimi"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSifrePage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (rol == 'admin')
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.api),
                  label: const Text('Nebim API Test'),
                  onPressed: () async {
                    try {
                      final sonuc = await NebimApiService.testConnection();

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('NEBIM TEST: $sonuc'),
                          duration: const Duration(seconds: 10),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('NEBIM HATA: $e'),
                          duration: const Duration(seconds: 10),
                        ),
                      );
                    }
                  },
                ),
              ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _sifreDegistir(context),
              icon: const Icon(Icons.lock_reset),
              label: const Text('Şifre Değiştir'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await AuthService.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
