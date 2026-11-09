# 🔴 PokéDex – Ensiklopedia Pokémon Berbasis Flutter

Proyek Akhir Praktikum Pemrograman Mobile (Flutter)

Aplikasi ensiklopedia Pokémon yang mengambil data dari **PokéAPI**, dengan autentikasi dan
penyimpanan favorit per pengguna di **Supabase**. Dibangun dengan Flutter, GetX, dan
penyimpanan lokal untuk cache.

## 👥 Kelompok

| Nama | NIM | Peran |
|---|---|---|
| _Nama Anggota 1_ | _NIM_ | _mis. Auth & Supabase_ |
| _Nama Anggota 2 (jika ada)_ | _NIM_ | _mis. UI & API_ |

Tema: **PokéDex – Ensiklopedia Pokémon**

## 📸 Tampilan Aplikasi

| Login | Beranda | Detail | Favorit | Profil |
|---|---|---|---|---|
| _screenshot_ | _screenshot_ | _screenshot_ | _screenshot_ | _screenshot_ |

> Ganti dengan tangkapan layar di folder `docs/screenshots/`.

## ✨ Fitur

**Autentikasi (Supabase Auth)**
- Register, login, logout dengan email dan password
- Session tersimpan (tetap login saat aplikasi dibuka kembali)
- Validasi form dan pesan kesalahan
- Proteksi halaman: tanpa login diarahkan ke halaman Login
- Profil pengguna

**Ensiklopedia Pokémon (PokéAPI)**
- Daftar Pokémon dengan infinite scroll
- Pencarian berdasarkan nama dan filter berdasarkan tipe
- Detail: gambar, ID, tipe, tinggi, berat, kemampuan, statistik dasar
- Penanganan loading, error koneksi, dan hasil kosong

**Favorit (Supabase Database)**
- Tambah dan hapus favorit
- Data tersimpan di cloud dan terpisah per akun (Row Level Security)

**Penyimpanan lokal**
- Cache data Pokémon, daftar nama, dan daftar tipe
- Riwayat pencarian (lihat, hapus satu, hapus semua)

**Fitur tambahan**
- Notifikasi lokal: pengingat harian untuk menjelajahi Pokémon
- Location-Based Service (opsional): menampilkan koordinat pengguna
- GetX untuk state management, dependency injection, dan navigasi
- Halaman Tentang

## ✅ Pemenuhan Ketentuan Final Project

| Ketentuan | Implementasi |
|---|---|
| Tema/ide jelas | Ensiklopedia Pokémon |
| Autentikasi/otorisasi | Supabase Auth + RLS (data favorit hanya milik pemilik akun) |
| CRUD | Lihat tabel di bawah |
| Seluruh materi praktikum | Lihat pemetaan modul di bawah |
| GetX (bonus) | ✅ Controller, reactive state (`Rx`, `Obx`), `Get.put/find`, `GetPage`, middleware |
| LBS (bonus) | ✅ Geolocator (izin, cek layanan, ambil koordinat) |

### Operasi CRUD

| Operasi | Data | Implementasi |
|---|---|---|
| Create | Akun, profil, favorit | Register; tombol ♥ menambah favorit |
| Read | Pokémon, profil, favorit, riwayat | Daftar/detail Pokémon (API), halaman Profil dan Favorit (Supabase) |
| Update | Profil pengguna | Ubah username di halaman Profil |
| Delete | Favorit, riwayat pencarian | Hapus favorit; hapus riwayat |

## 📚 Pemetaan Materi Praktikum

| Materi | Implementasi |
|---|---|
| Setup Flutter | Struktur proyek, dependensi di `pubspec.yaml` |
| OOP & Dart | Model `Pokemon`, `PokemonStat`, `Profile`; class service dan controller |
| Widgets | Form auth, `PokemonCard`, grid/list, chip, navigation bar |
| State & Data | Controller reaktif: daftar, pencarian, filter, favorit |
| Navigation | Login → Register → Home → Detail → Riwayat → Tentang (GetX routes) |
| HTTP Request | `PokemonApiService` memanggil PokéAPI |
| Local Storage | `LocalDatabase` (SharedPreferences): cache dan riwayat |
| Notification | `NotificationService` (flutter_local_notifications) |
| Location-Based Service | `LocationService` (geolocator) |
| Advanced Flutter / GetX | Controller, dependency management, middleware |
| Cloud | Supabase Auth dan Database |

## 🛠️ Teknologi

Flutter • Dart • GetX • http • supabase_flutter • shared_preferences •
flutter_local_notifications • geolocator • PokéAPI • Supabase

## 🗂️ Struktur Folder

```
lib/
├── main.dart
├── config.dart                  # konfigurasi via --dart-define
├── models/                      # pokemon.dart, profile.dart
├── services/                    # pokemon_api, supabase, notification, location
├── controllers/                 # auth, pokemon, favorite (GetX)
├── pages/                       # splash, login, register, home, detail,
│                                # favorite, profile, history, about
├── widgets/                     # pokemon_card, search_bar, type_chip, loading
├── database/                    # local_database.dart
├── routes/                      # app_routes.dart + AuthMiddleware
└── utils/                       # warna tipe, label statistik
supabase/schema.sql              # tabel, RLS, trigger
```

## 🗄️ Database (Supabase)

- `profiles` (`id` → `auth.users.id`, `username`, `created_at`)
- `favorites` (`id`, `user_id` default `auth.uid()`, `pokemon_id`, `created_at`, unik `user_id + pokemon_id`)
- RLS aktif: pengguna hanya dapat membaca, menambah, dan menghapus data miliknya.
- Profil dibuat otomatis lewat trigger setelah registrasi.

Skema lengkap: [`supabase/schema.sql`](supabase/schema.sql)

## 🚀 Menjalankan Proyek

**Prasyarat:** Flutter ≥ 3.27, Android Studio / SDK, akun Supabase.

1. **Siapkan Supabase**
   - Buat proyek di https://supabase.com/dashboard
   - Jalankan isi `supabase/schema.sql` di **SQL Editor**
   - (Pengembangan) matikan *Confirm email* di Authentication > Providers > Email
   - Salin **Project URL** dan **publishable key** dari Project Settings > API
2. **Clone dan install**
   ```bash
   git clone <url-repository-ini>
   cd pokedex
   flutter pub get
   ```
3. **Konfigurasi Android**
   - `android/app/src/main/AndroidManifest.xml`: tambahkan izin `INTERNET`, `POST_NOTIFICATIONS`,
     `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
   - `android/app/build.gradle.kts`: aktifkan `isCoreLibraryDesugaringEnabled = true` di `compileOptions`
     dan tambahkan `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` di `dependencies`
4. **Jalankan**
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
     --dart-define=SUPABASE_PUBLISHABLE_KEY=isi_publishable_key
   ```

### Build APK

> Folder `android/` dibuat otomatis (`flutter create` + `tool/patch_android.py`), jadi langkah 3 di atas
> sudah otomatis. Untuk build di cloud tanpa install apa pun, lihat [`docs/BUILD_APK.md`](docs/BUILD_APK.md)
> (GitHub Actions).

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=isi_publishable_key
```
Hasil: `build/app/outputs/flutter-apk/app-release.apk`

## 🔒 Keamanan

- Password dikelola Supabase Auth, tidak disimpan di tabel aplikasi.
- RLS pada `profiles` dan `favorites`; `user_id` diisi database (`auth.uid()`), bukan dikirim aplikasi.
- Hanya publishable key yang dipakai di aplikasi. **Secret/service_role key tidak pernah dimasukkan ke kode.**
- Kunci diberikan lewat `--dart-define`, tidak di-commit ke repository.

## 🧪 Skenario Pengujian

- [ ] Register akun baru dan login
- [ ] Validasi input dan login gagal
- [ ] Session bertahan setelah aplikasi ditutup dan dibuka lagi
- [ ] Logout dan proteksi halaman
- [ ] Daftar dan detail Pokémon tampil dari API
- [ ] Pencarian dan filter tipe
- [ ] Tambah/hapus favorit dan tetap ada setelah login ulang
- [ ] Akun A tidak dapat melihat favorit akun B (RLS)
- [ ] Ubah username di Profil
- [ ] Loading, error koneksi, dan data kosong
- [ ] Cache dan riwayat pencarian
- [ ] Notifikasi pengingat dan fitur lokasi

## ⚠️ Batasan

- Fokus pada ensiklopedia, bukan permainan Pokémon.
- Cache lokal belum memiliki masa kedaluwarsa.
- Chatbot/AI di luar ruang lingkup.

## 🙏 Sumber & Atribusi

- Data: [PokéAPI](https://pokeapi.co)
- Backend: [Supabase](https://supabase.com)
- Pokémon dan nama karakter terkait adalah merek dagang Nintendo / Game Freak / The Pokémon Company.
  Proyek ini dibuat untuk tujuan pembelajaran.
