# Smart Price Tracker

Smart Price Tracker adalah aplikasi mobile berbasis Flutter yang membantu pengguna untuk melacak harga barang dari berbagai sumber (Google Shopping API via SerpApi) dan menemukan penawaran terbaik menggunakan **analisis harga berbasis AI**.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🔍 **Pencarian Produk** | Cari produk dari Google Shopping API secara real-time |
| 🤖 **Analisis AI** | Otomatis memberi label *Best Deal*, *Overpriced*, atau *Normal* berdasarkan analisis statistik harga |
| 🎨 **UI Premium** | Design system "The Financial Atelier" — minimalis, editorial, dan modern |
| 🌐 **Buka di Browser** | Tap produk untuk langsung membuka halaman toko di browser |
| 📊 **Prediksi Harga** | Simulasi prediksi harga minggu depan (Predictive Analytics) |

## 🧠 Cara Kerja AI (Price Analysis)

Fitur utama aplikasi ini adalah **analisis harga otomatis** yang memberikan label kecerdasan buatan pada setiap produk:

### Algoritma

```
1. Ambil data produk dari Google Shopping API
2. Filter produk yang memiliki harga valid (> 0)
3. Hitung rata-rata (mean) dari seluruh harga valid
   → μ = Σ(price_i) / n
4. Bandingkan setiap harga produk terhadap rata-rata:
```

| Kondisi | Label | Penjelasan |
|---------|-------|------------|
| `price ≤ avg × 0.9` | 🔥 **Best Deal** | Harga ≥10% lebih murah dari rata-rata |
| `price > avg` | 📈 **Overpriced** | Harga di atas rata-rata pasar |
| `avg×0.9 < price ≤ avg` | ✅ **Normal** | Harga wajar, sekitar rata-rata |

### Contoh Skenario

Misal ada 5 produk dengan harga: `Rp 800k, 900k, 1jt, 1.1jt, 1.5jt`
- Rata-rata = **Rp 1.060.000**
- Threshold Best Deal = `1.060.000 × 0.9` = **Rp 954.000**
- Produk `Rp 800k` dan `Rp 900k` → **Best Deal** ✅
- Produk `Rp 1.1jt` dan `Rp 1.5jt` → **Overpriced** ⚠️
- Produk `Rp 1jt` → **Normal**

## 🏗 Folder Structure (Clean Architecture)

Aplikasi ini mendesain struktur menggunakan pendekatan **Clean Architecture** berbasis fitur (feature-driven) agar *codebase* tetap rapi, scalable, terpisah komponennya dengan baik, dan mudah untuk di-test.

```
lib/
 ┣ core/                # Konfigurasi aplikasi, helper, koneksi API
 ┃ ┗ network/
 ┃   ┗ api_service.dart # Service untuk memanggil Google Shopping API via SerpApi
 ┣ features/            # Daftar module/fitur pada aplikasi
 ┃ ┗ product/           # Fitur Product (pencarian dan pelacakan harga)
 ┃   ┣ data/
 ┃   ┃ ┗ models/
 ┃   ┃   ┗ product_model.dart   # Model data Product + fromJson parser
 ┃   ┣ domain/
 ┃   ┃ ┗ usecases/
 ┃   ┃   ┗ price_analyzer.dart  # ⭐ Engine AI analisis harga (Best Deal/Overpriced)
 ┃   ┗ presentation/
 ┃     ┗ pages/
 ┃       ┗ home_screen.dart     # UI utama: search, product cards, AI badges
 ┗ main.dart            # Entry point aplikasi
```

## 🛠 Teknologi & Dependencies

| Teknologi | Kegunaan |
|-----------|----------|
| **Flutter** | Framework UI cross-platform |
| **Dart** | Bahasa pemrograman |
| **Clean Architecture** | Pattern arsitektur |
| **google_fonts** | Typography Inter via Google Fonts |
| **http** | HTTP client untuk API calls |
| **url_launcher** | Membuka URL produk di browser |
| **flutter_dotenv** | Manajemen API key yang aman |

## 🎨 Design System — "The Financial Atelier"

Desain UI menggunakan sistem dari Stitch MCP dengan pendekatan **editorial minimalis**:

- **Primary Color**: Deep Teal `#27676E`
- **Background**: Off-white `#F8FAFA`
- **Font**: Inter (via GoogleFonts)
- **Prinsip**: No-Line Rule (tanpa border, gunakan background shifts)
- **Shadow**: Ambient shadow 4% opacity ("felt, not seen")
- **Badge**: Pill-shaped containers dengan warna semantik

## 🚀 Cara Menjalankan

```bash
# 1. Clone repository
git clone <repository-url>

# 2. Masuk ke direktori project
cd price-tracker

# 3. Buat file .env di root project
echo "SERPAPI_KEY=your_api_key_here" > .env

# 4. Install dependencies
flutter pub get

# 5. Jalankan aplikasi
flutter run
```

## 📄 Pembaruan Berkala
README ini didesain sebagai _living document_ dan akan diperbarui secara berkala seiring dengan penambahan fitur, dependensi baru, dan integrasi API lainnya ke dalam project.
