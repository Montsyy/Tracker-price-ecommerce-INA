# 🛍️ Smart Price Tracker: Smart Shopping Assistant

**Smart Price Tracker** adalah platform asisten belanja cerdas berbasis Flutter yang dirancang untuk membantu konsumen Indonesia mendapatkan harga terbaik secara objektif. Dengan mengintegrasikan data real-time dari berbagai marketplace besar melalui Google Shopping API (SerpApi), aplikasi ini mengeliminasi kebingungan saat membandingkan harga secara manual.

---

## 🎯 Maksud & Tujuan Aplikasi

Di tengah banyaknya pilihan marketplace di Indonesia, variasi harga untuk satu produk yang sama bisa sangat signifikan. **Tujuan utama** aplikasi ini adalah:
1.  **Transparency**: Memberikan transparansi harga pasar yang sebenarnya dari berbagai toko besar.
2.  **Effortless Comparison**: Menghemat waktu pengguna dengan mengumpulkan data dari Shopee, Tokopedia, Lazada, Blibli, dan TikTok Shop dalam satu layar.
3.  **Data-Driven Decision**: Membantu pengguna memutuskan apakah sekarang adalah waktu yang tepat untuk membeli atau sebaiknya menunggu, menggunakan analisis statistik dan prediksi AI.
4.  **Avoiding Scams**: Memfilter produk dengan harga yang tidak masuk akal (produk dummy atau jasa) untuk memastikan data yang dianalisis adalah produk fisik asli.

---

## ✨ Fitur Unggulan

| Fitur | Deskripsi |
|-------|-----------|
| 🤖 **AI Price Labeling** | Memberikan label otomatis: **Best Deal**, **Normal**, atau **Overpriced** berdasarkan posisi harga relatif terhadap rata-rata pasar. |
| 📊 **Interactive Market Chart** | Grafik batang interaktif yang membandingkan 5 toko teratas. Setiap batang dapat di-klik untuk langsung menuju toko tersebut. |
| 🔮 **Predictive Analytics** | Simulasi prediksi harga untuk **bulan depan** membantu pengguna merencanakan pengeluaran di masa mendatang. |
| 🇮🇩 **Local Marketplace Focus** | Filter cerdas yang memprioritaskan e-commerce populer di Indonesia: *Lazada, Shopee, Tokopedia, TikTok Shop, dan Blibli*. |
| 🛡️ **Smart Price Filtering** | Otomatis mengabaikan produk dengan harga di bawah Rp 1.000 untuk menjaga akurasi statistik rata-rata pasar. |
| 🎨 **Editorial Design System** | Menggunakan "The Financial Atelier" design system — visual premium, minimalis, dan editorial yang mengutamakan keterbacaan data. |

---

## 🧠 Cara Kerja Sistem (The Intelligence Engine)

Aplikasi ini menggunakan `PriceAnalyzer` sebagai pusat logika bisnis untuk memproses data mentah menjadi wawasan yang berguna.

### 1. Analisis Statistik (Market Benchmarking)
Sistem menghitung nilai rata-rata (*Mean*) dari hasil pencarian yang valid.
-   **Best Deal**: Harga ≤ 90% dari rata-rata (Artinya hemat minimal 10% dibanding pasar).
-   **Overpriced**: Harga > rata-rata pasar.
-   **Normal**: Harga wajar di kisaran pasar.

### 2. Prediksi Harga (Month-Ahead Prediction)
Menggunakan algoritma *random walk* terkontrol (±5% volatilitas) untuk mensimulasikan pergerakan harga di bulan berikutnya. Ini memberikan gambaran psikologis bagi pengguna untuk mempertimbangkan urgensi pembelian.

### 3. Filter Marketplace Indonesia
Sistem melakukan *String Similarity Matching* pada nama toko untuk memastikan grafik perbandingan hanya menampilkan platform terpercaya di Indonesia, menghindari data dari toko personal yang tidak relevan di luar negeri.

---

## 🏗 Struktur Arsitektur (Clean Architecture)

Aplikasi ini dibangun dengan memisahkan tanggung jawab (Separation of Concerns) secara ketat:

-   **Data Layer**: Mengelola komunikasi API (`ApiService`) dan pemetaan JSON ke obyek Dart (`ProductModel`).
-   **Domain Layer**: Berisi logika bisnis inti (`PriceAnalyzer`) yang independen dari framework UI.
-   **Presentation Layer**: Kumpulan widget UI yang responsif dan komponen visual (`HomeScreen`, `PriceComparisonChart`).

---

## 🛠 Teknologi Utama

-   **Flutter & Dart**: Performa native untuk Android & iOS.
-   **SerpApi (Google Shopping API)**: Data marketplace real-time yang akurat.
-   **FL Chart / Custom Bar Painting**: Visualisasi data yang dinamis.
-   **The Financial Atelier (Stitch)**: Sistem desain yang memberikan kesan mewah dan profesional.

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

Proyek ini dikembangkan sebagai solusi belanja cerdas bagi masyarakat Indonesia. Kontribusi sangat terbuka untuk improvisasi algoritma AI atau integrasi marketplace lokal lainnya secara langsung.

---
*Developed with ❤️ by Dhafi Putra Alfarezi.*
