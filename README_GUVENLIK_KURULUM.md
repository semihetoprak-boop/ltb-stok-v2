# LTB STOK V2 — Auth + RLS Güvenlik Geçişi

Bu sürüm mevcut `users.sifre` sorgusunu kaldırır ve Supabase Auth oturumuna geçer.

## ÖNEMLİ: Kurulum sırası

### 1. Supabase Dashboard > Authentication > Users

Mevcut her uygulama kullanıcısı için Auth kullanıcısı oluşturun.

E-posta formatı zorunlu olarak:

- `admin@ltbstok.local`
- `m129_mudur@ltbstok.local`
- `m129_p@ltbstok.local`
- `m163_mudur@ltbstok.local`
- `m163_p@ltbstok.local`

Kullanıcı kodu neyse e-postanın `@` öncesi aynı olmalıdır.

**Eski `1234` şifresini kullanmayın.** Her kullanıcıya güçlü ve ayrı bir geçici şifre verin.
Dashboard üzerinden kullanıcı oluştururken e-postayı onaylı/confirmed oluşturun.

### 2. Supabase Dashboard > SQL Editor

`supabase/migrations/001_auth_rls_security.sql` dosyasının tamamını çalıştırın.

Bu SQL:
- `profiles` tablosunu oluşturur.
- Auth kullanıcısını eski kullanıcı kodu/rol/mağaza kaydıyla eşler.
- `stoklar`, `mağazalar`, `raflar` için RLS açar.
- Raf yazma/silme işlemlerini admin veya kullanıcının kendi mağaza müdürü ile sınırlar.
- Eski `users` tablosunu anon/authenticated istemci erişimine kapatır.

### 3. Kontrol

Table Editor > `profiles` tablosunda oluşturduğunuz Auth kullanıcılarının tamamı görünmelidir.

Beklenen alanlar:
- id
- kullanici_kodu
- rol
- magaza

Eksik profil varsa uygulamaya geçmeyin.

### 4. Uygulamayı test edin

```bash
flutter analyze
flutter run -d chrome
```

Eski `1234` yerine Authentication > Users ekranında verdiğiniz yeni şifreyle giriş yapın.

Test sırası:
1. Personel girişi
2. Barkod
3. Barkodsuz arama
4. Diğer mağaza stokları
5. Müdür girişi
6. Raf ekleme
7. Raf güncelleme
8. Raf silme
9. Çıkış

## Güvenlik sonucu

- Şifre artık `public.users.sifre` üzerinden okunmaz.
- Flutter uygulaması şifre doğrulamaz.
- Şifre doğrulama Supabase Auth tarafından yapılır.
- Oturum JWT ile taşınır.
- RLS veritabanı seviyesinde yetki uygular.
- Personel raf yazamaz.
- Müdür yalnızca kendi mağazasının rafını değiştirebilir.
- Eski `users` tablosu web istemcisine kapalıdır.

## Sonraki güvenlik aşaması

Nebim API için Netlify Function/backend proxy, secret environment variables, JWT doğrulama, timeout, güvenli hata/log yönetimi ve `NebimStockRepository` iskeleti hazırlanacaktır.
