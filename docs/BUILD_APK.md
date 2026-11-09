# Build APK

Folder `android/` tidak ikut di-commit. Folder itu dibuat otomatis oleh
`flutter create`, lalu `tool/patch_android.py` menambahkan izin dan konfigurasi
desugaring yang dibutuhkan (menggantikan langkah "Konfigurasi Android" manual di README).

## Cara 1: GitHub Actions (tanpa install apa pun)

1. Buat repository GitHub, lalu push seluruh isi folder proyek ini ke branch `main`.
2. Buka **Settings > Secrets and variables > Actions > New repository secret**, lalu isi:
   - `SUPABASE_URL`: Project URL dari Supabase
   - `SUPABASE_PUBLISHABLE_KEY`: publishable key (jangan pakai secret/service_role key)
3. Buka tab **Actions > Build APK > Run workflow** (atau cukup push ke `main`).
4. Setelah selesai (sekitar 5 sampai 10 menit), unduh `pokedex-apk` dari bagian **Artifacts**,
   ekstrak, dan pasang `app-release.apk` di HP.

## Cara 2: Di laptop

Prasyarat: Flutter 3.27 atau lebih baru, Android SDK, JDK 17.

```bash
flutter create --platforms=android --project-name pokedex --org id.ac.upnyk .
python3 tool/patch_android.py
rm -rf test
flutter pub get
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=isi_publishable_key
```

Hasil: `build/app/outputs/flutter-apk/app-release.apk`

## Sebelum dipakai

Jalankan `supabase/schema.sql` di Supabase **SQL Editor**. Untuk pengembangan, matikan
*Confirm email* di Authentication > Providers > Email agar register langsung login.
