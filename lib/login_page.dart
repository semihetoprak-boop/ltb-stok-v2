import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final kullaniciController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Future<void> girisYap() async {
    final kullanici = kullaniciController.text.trim();
    final sifre = passwordController.text.trim();

    if (kullanici.isEmpty || sifre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı adı ve şifre giriniz.")),
      );
      return;
    }

    final sonuc = await SupabaseService.client
        .from('users')
        .select()
        .eq('kullanici_kodu', kullanici)
        .eq('sifre', sifre);

    if (sonuc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı adı veya şifre yanlış.")),
      );
      return;
    }
    final kullaniciBilgisi = sonuc.first;

    final rol = kullaniciBilgisi['rol'];
    final magaza = kullaniciBilgisi['mağaza'];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HomePage(kullanici: kullanici, rol: rol, magaza: magaza),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LTB STOK"), centerTitle: true),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Giriş Yap",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: kullaniciController,
                decoration: const InputDecoration(
                  labelText: "Kullanıcı Adı",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Şifre",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: girisYap,
                  child: const Text("Giriş Yap"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
