# Project Hirelens (Android)

## PERINGATAN!!

Sebelum project ini dijalankan, selalu jalankan perintah ini jika VS Code tidak menjalankannya secara otomatis!

```
flutter pub get
```

- ### Cara Jalankan (development)

    - Colok Handphone ke PC (pastikan anda sudah menginstal ADB atau Android Studio)

    - Pastikan debug USB di Handphone (android) sudah aktif di menu pengembang (Developer Options)

    - Pastikan Handphone sudah terbaca di VS Code

        ![alt text](<docs_src/Cuplikan layar 2025-08-23 210410.png>)

    - Tekan `F5` untuk menjalankan aplikasi.

- ### Cara Build APK (release)

    - Jalankan command ini.

        ```
        flutter clean build && flutter pub get && flutter build apk --release
        ```

    - Hasil build tersimpan di folder
    `build/app/outputs/apk/release/app-release.apk`