import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSifrePage extends StatefulWidget {
  const AdminSifrePage({super.key});

  @override
  State<AdminSifrePage> createState() => _AdminSifrePageState();
}

class _AdminSifrePageState extends State<AdminSifrePage> {
  final kullaniciController = TextEditingController();
  final sifreController = TextEditingController();

  bool yukleniyor = false;

  Future<void> sifreDegistir() async {
    final kullaniciKodu = kullaniciController.text.trim();
    final yeniSifre = sifreController.text;

    if (kullaniciKodu.isEmpty || yeniSifre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı kodu ve yeni şifre giriniz.')),
      );
      return;
    }

    if (yeniSifre.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre en az 6 karakter olmalı.')),
      );
      return;
    }

    setState(() => yukleniyor = true);

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'admin-change-password',
        body: {'kullaniciKodu': kullaniciKodu, 'yeniSifre': yeniSifre},
      );

      if (!mounted) return;

      final data = response.data;

      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      kullaniciController.clear();
      sifreController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre başarıyla değiştirildi.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) {
        setState(() => yukleniyor = false);
      }
    }
  }

  @override
  void dispose() {
    kullaniciController.dispose();
    sifreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Yönetimi'), centerTitle: true),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 70),
                const SizedBox(height: 20),
                const Text(
                  'Kullanıcı Şifresi Değiştir',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: kullaniciController,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Kodu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: sifreController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: yukleniyor ? null : sifreDegistir,
                    icon: const Icon(Icons.password),
                    label: yukleniyor
                        ? const CircularProgressIndicator()
                        : const Text('Şifreyi Değiştir'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
