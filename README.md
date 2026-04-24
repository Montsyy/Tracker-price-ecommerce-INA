# 🛍️ Smart Price Tracker: Smart Shopping Assistant

**Smart Price Tracker** adalah platform asisten belanja cerdas berbasis Flutter yang dirancang untuk membantu konsumen Indonesia mendapatkan harga terbaik secara objektif. Dengan mengintegrasikan data real-time dari berbagai marketplace besar melalui Google Shopping API (SerpApi), aplikasi ini mengeliminasi kebingungan saat membandingkan harga secara manual.

---

## 🎯 Maksud & Tujuan Aplikasi

Di tengah banyaknya pilihan marketplace di Indonesia, variasi harga untuk satu produk yang sama bisa sangat signifikan. **Tujuan utama** aplikasi ini adalah:
1.  **Transparency**: Memberikan transparansi harga pasar yang sebenarnya dari berbagai toko besar.
2.  **Effortless Comparison**: Menghemat waktu pengguna dengan mengumpulkan data dari Shopee, Tokopedia, Lazada, Blibli, dll dalam satu layar.
3.  **Data-Driven Decision**: Membantu pengguna memutuskan apakah sekarang adalah waktu yang tepat untuk membeli atau sebaiknya menunggu, menggunakan analisis statistik dan prediksi AI.
4.  **Avoiding Scams**: Memfilter produk dengan harga yang tidak masuk akal (produk dummy atau jasa) untuk memastikan data yang dianalisis adalah produk fisik asli.

---

## ✨ Fitur Unggulan

| Fitur | Deskripsi |
|-------|-----------|
| 🤖 **AI Price Labeling** | Memberikan label otomatis: **Best Deal**, **Normal**, atau **Overpriced** berdasarkan posisi harga relatif terhadap rata-rata pasar. |
| 🛒 **Smart Shopping Cart** | Simpan produk favorit Anda dengan sistem **persistensi data** (Shared Preferences). |
| 🔀 **Adaptive Layout Toggle** | Pilih tampilan favorit Anda: **List View** yang informatif atau **Grid View (2 Kolom)** yang modern dengan thumbnail produk 1:1 yang besar. |
| 📊 **Interactive Market Chart** | Grafik batang interaktif yang membandingkan toko teratas untuk visualisasi harga yang jernih. |
| 🔮 **Predictive Analytics** | Simulasi prediksi harga untuk **bulan depan** dengan data yang konsisten (cached) untuk membantu perencanaan keuangan. |
| 🇮🇩 **Local Marketplace Focus** | Filter cerdas yang memprioritaskan e-commerce populer di Indonesia: *Lazada, Shopee, Tokopedia, dll*. |
| 🛡️ **Smart Price Filtering** | Membuang produk di bawah Rp 1.000, menyaring kata kunci sampah, dan mendeteksi anomali harga (*Outlier Detection*) untuk akurasi AI. |
| 🌟 **Store Reliability Badge** | Mengevaluasi skor `rating` dan `reviews` untuk melabeli kredibilitas toko. |
| 🎨 **Editorial Design System** | Menggunakan "The Financial Atelier" design system — visual premium, minimalis, dan profesional. |

---

## 🧠 Cara Kerja Sistem (The Intelligence Engine)

Aplikasi ini menggunakan `PriceAnalyzer` sebagai pusat logika bisnis untuk memproses data mentah menjadi wawasan yang berguna.

### 1. Analisis Statistik & Outlier Detection
Sistem membersihkan data mentah dari *noise* dan membuang produk yang harganya terindikasi anomali (< 50% dari *Median* harga). Dari sisa data bersih, sistem menghitung rata-rata (*Mean*):
-   **Best Deal**: Harga ≤ 90% dari rata-rata (Artinya hemat minimal 10% dibanding pasar).
-   **Overpriced**: Harga > rata-rata pasar.

### 2. Smart Cart & Persistensi
Menggunakan `Provider` sebagai state management global untuk mengelola keranjang belanja. Data disimpan secara lokal di perangkat, sehingga daftar belanja Anda tetap tersedia meskipun aplikasi ditutup dan dibuka kembali.

### 3. Prediksi Harga Konsisten
Menggunakan algoritma *random walk simulation* (±5% volatilitas). Hasil prediksi di-cache selama sesi pencarian berlangsung untuk memastikan angka yang ditampilkan tetap konsisten saat Anda mengganti layout atau melakukan interaksi UI lainnya.

### 4. Layout Fleksibel
Implementasi `SliverGrid` dan `SliverList` yang dinamis memberikan transisi mulus antara mode List dan Grid, memastikan pengalaman pengguna yang responsif di berbagai ukuran layar.

---

## 🏗 Struktur Arsitektur (Clean Architecture)

Aplikasi ini dibangun dengan memisahkan tanggung jawab (Separation of Concerns) secara ketat:

-   **Data Layer**: Komunikasi API (`ApiService`) dan pemetaan JSON (`ProductModel`).
-   **Domain Layer**: Logika bisnis inti (`PriceAnalyzer`) yang independen.
-   **Presentation Layer**: UI yang reaktif dengan state management `Provider`.

---

## 🛠 Teknologi Utama

-   **Flutter & Dart**: Performa cross-platform unggulan.
-   **Provider**: State management yang efisien dan skalabel.
-   **Shared Preferences**: Penyimpanan data lokal untuk fitur keranjang.
-   **SerpApi (Google Shopping)**: Sumber data marketplace real-time.
-   **URL Launcher**: Integrasi browser eksternal untuk transaksi.
-   **The Financial Atelier**: Sistem desain premium dan minimalis.

---

## 🚀 Cara Instalasi

1.  **Clone & Install**:
    ```bash
    git clone https://github.com/Montsyy/price-tracker-id.git
    cd price-tracker
    flutter pub get
    ```
2.  **Konfigurasi API Key**:
    Buat file `.env` di root folder dan masukkan API Key dari [SerpApi](https://serpapi.com/):
    ```env
    SERPAPI_KEY=masukkan_api_key_anda_di_sini
    ```
3.  **Run**:
    ```bash
    flutter run
    ```

---

## 📄 Lisensi & Kontribusi

Proyek ini dikembangkan sebagai solusi belanja cerdas bagi masyarakat Indonesia. Kontribusi sangat terbuka untuk improvisasi algoritma AI.

---
*Developed with ❤️ by Dhafi Putra Alfarezi.*ritma AI.

---
*Developed with ❤️ by Dhafi Putra Alfarezi.*
