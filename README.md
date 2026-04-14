# Smart Price Tracker

Smart Price Tracker adalah aplikasi mobile berbasis Flutter yang membantu pengguna untuk melacak harga barang dari berbagai sumber (seperti Google Shopping API) dan menemukan penawaran terbaik.

## 🏗 Folder Structure (Clean Architecture)

Aplikasi ini mendesain struktur menggunakan pendekatan **Clean Architecture** berbasis fitur (feature-driven) agar *codebase* tetap rapi, scalable, terpisah komponennya dengan baik, dan mudah untuk di-test.

\`\`\`
lib/
 ┣ core/               # Konfigurasi aplikasi, helper, network, koneksi API, routing, dan utility yang reusable di seluruh fitur.
 ┣ features/           # Daftar module/fitur pada aplikasi.
 ┃ ┗ product/          # Fitur Product (pencarian dan pelacakan harga).
 ┃   ┣ data/           # Layer Data: Models (response API), Data Sources (pemanggil API), dan Repositories Implementation.
 ┃   ┣ domain/         # Layer Domain: Entities (Core business logic), Use Cases, dan Repositories Interfaces.
 ┃   ┗ presentation/   # Layer Presentation: Pages (UI), Widgets spesifik fitur, dan State Management (Bloc/Provider, dll).
 ┗ main.dart           # Entry point aplikasi.
\`\`\`

## 🚀 Fitur Saat Ini
- Struktur awal Clean Architecture sudah dibuat.
- Model `Product` dibuat (`product_model.dart`) untuk menampung/parsing data respons dari Google Shopping API.

## 🛠 Teknologi Utama
- **Framework**: Flutter
- **Bahasa Pemrograman**: Dart
- **Arsitektur**: Clean Architecture

## 📄 Pembaruan Berkala
README ini didesain sebagai _living document_ dan akan diperbarui secara berkala seiring dengan penambahan fitur, dependensi baru, dan integrasi API lainnya ke dalam project.
