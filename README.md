# Project Hirelens (Android)

## PERINGATAN!!

Perhatikan file `assets/.env`. Jika tidak ada, buat file `.env` dari file `.env.example` yang sudah disediakan dan isi sesuai konteks dari key yang ada.

## Cara Jalankan (development)

- Colok Handphone ke PC (pastikan anda sudah menginstal ADB atau Android Studio)

- Pastikan debug USB di Handphone (android) sudah aktif di menu pengembang (Developer Options)

- Pastikan Handphone sudah terbaca di VS Code

    ![alt text](<docs_src/Cuplikan layar 2025-08-23 210410.png>)

- Tekan `F5` untuk menjalankan aplikasi.

## Cara Build APK (release)

- Jalankan command ini.

    ```
    flutter clean build && flutter pub get && flutter build apk --release
    ```

- Hasil build tersimpan di folder
`build/app/outputs/apk/release/app-release.apk`
## BONUS : Git on VS Code Tutorial

![alt text](<docs_src/Cuplikan layar 2025-08-23 212712.png>)

1. Biru

2. Hijau

3. Merah = Untuk cek apakah ada update di repository github

4. Tombol `commit` di screenshot akan berubah menjadi `Sync Changes` jika ada update dari github.