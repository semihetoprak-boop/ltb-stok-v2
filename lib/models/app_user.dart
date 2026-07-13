class AppUser {
  final String id;
  final String kullaniciKodu;
  final String rol;
  final String magaza;

  const AppUser({
    required this.id,
    required this.kullaniciKodu,
    required this.rol,
    required this.magaza,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'].toString(),
      kullaniciKodu: (map['kullanici_kodu'] ?? '').toString(),
      rol: (map['rol'] ?? '').toString(),
      magaza: (map['magaza'] ?? '').toString(),
    );
  }
}
