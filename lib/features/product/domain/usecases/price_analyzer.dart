import 'dart:math';

import '../../data/models/product_model.dart';

/// ══════════════════════════════════════════════════════════════════════
/// AnalyzedProduct — Wrapper yang menggabungkan data produk mentah
/// dengan label hasil analisis AI.
///
/// Setiap produk yang telah dianalisis akan dibungkus dalam class ini,
/// sehingga UI dapat menampilkan badge label berdasarkan analisis harga.
///
/// Contoh label:
///  - 'Best Deal'   → Harga signifikan lebih murah dari rata-rata
///  - 'Overpriced'  → Harga di atas rata-rata pasar
///  - 'Normal'      → Harga wajar (sekitar rata-rata)
///  - 'No Price'    → Data harga tidak tersedia (harga = 0)
///  - 'Unknown'     → Tidak cukup data untuk dianalisis
/// ══════════════════════════════════════════════════════════════════════
class AnalyzedProduct {
  /// Data produk asli dari API (title, price, store, dll.)
  final Product product;

  /// Label hasil analisis AI, ditampilkan sebagai badge di UI
  final String label;

  AnalyzedProduct({
    required this.product,
    required this.label,
  });
}

/// ══════════════════════════════════════════════════════════════════════
/// PriceAnalyzer — Engine analisis harga berbasis statistik.
///
/// Class ini bertanggung jawab untuk menganalisis daftar produk
/// dan memberikan label kecerdasan buatan pada setiap produk
/// berdasarkan posisi harganya relatif terhadap rata-rata pasar.
///
/// ❓ MENGAPA PENDEKATAN INI?
/// Pendekatan statistical pricing analysis dipilih karena:
///  1. Tidak memerlukan model ML yang berat (ringan di mobile).
///  2. Dapat bekerja secara real-time tanpa koneksi ke server AI.
///  3. Memberikan insight yang actionable bagi pengguna.
///
/// 📊 ALGORITMA ANALISIS:
///  1. Filter produk yang memiliki harga valid (> 0).
///  2. Hitung rata-rata (mean) dari seluruh harga valid.
///  3. Bandingkan harga setiap produk terhadap rata-rata:
///     • Harga ≤ 90% rata-rata  →  "Best Deal"  (diskon ≥ 10%)
///     • Harga > rata-rata      →  "Overpriced"
///     • Sisanya                →  "Normal"
///
/// 🎯 TUJUAN:
/// Membantu pengguna mengidentifikasi penawaran terbaik secara
/// instan tanpa harus membandingkan harga secara manual.
/// ══════════════════════════════════════════════════════════════════════
class PriceAnalyzer {
  /// Menganalisis daftar produk dan memberikan label AI pada setiap item.
  ///
  /// **Parameter:**
  ///  - [products]: List produk mentah dari Google Shopping API.
  ///
  /// **Return:**
  ///  - List<AnalyzedProduct> yang sudah diberi label analisis.
  ///
  /// **Contoh penggunaan:**
  /// ```dart
  /// final analyzer = PriceAnalyzer();
  /// final results = analyzer.analyzePrice(products);
  /// // results[0].label → 'Best Deal'
  /// ```
  List<AnalyzedProduct> analyzePrice(List<Product> products) {
    if (products.isEmpty) return [];

    // ── STEP 1: Filter produk dengan harga valid ──
    // Produk dengan harga 0 diabaikan dalam perhitungan statistik
    // untuk menghindari distorsi pada rata-rata harga.
    final validProducts = products.where((p) => p.price > 0).toList();

    if (validProducts.isEmpty) {
      // Jika tidak ada data harga valid, labelkan semua sebagai 'Unknown'
      return products
          .map((p) => AnalyzedProduct(product: p, label: 'Unknown'))
          .toList();
    }

    // ── STEP 1.5: Outlier Detection (Hapus Aksesori/Barang Palsu) ──
    final sortedPrices = validProducts.map((p) => p.price).toList()..sort();
    final middle = sortedPrices.length ~/ 2;
    double median;
    if (sortedPrices.length % 2 == 1) {
      median = sortedPrices[middle];
    } else {
      median = (sortedPrices[middle - 1] + sortedPrices[middle]) / 2.0;
    }
    
    final minValidPrice = median * 0.5;
    
    // Filter produk yang harganya masuk akal (>= 50% median)
    final filteredProducts = validProducts.where((p) => p.price >= minValidPrice).toList();
    
    if (filteredProducts.isEmpty) {
      return products
          .map((p) => AnalyzedProduct(product: p, label: 'Unknown'))
          .toList();
    }

    // ── STEP 2: Kalkulasi Rata-Rata Harga (Mean) ──
    final total = filteredProducts.fold(0.0, (sum, item) => sum + item.price);
    final averagePrice = total / filteredProducts.length;

    // ── STEP 3: Proses Labeling berdasarkan threshold ──
    // Setiap produk dibandingkan terhadap rata-rata (averagePrice):
    //
    //  ┌─────────────────────┬──────────────────────────────┐
    //  │ Kondisi             │ Label                        │
    //  ├─────────────────────┼──────────────────────────────┤
    //  │ price == 0          │ 'No Price'                   │
    //  │ price ≤ avg * 0.9   │ 'Best Deal' (≥10% murah)    │
    //  │ price > avg         │ 'Overpriced'                 │
    //  │ avg*0.9 < price ≤ avg│ 'Normal'                    │
    //  └─────────────────────┴──────────────────────────────┘
    return products.map((product) {
      if (product.price == 0) {
        return AnalyzedProduct(product: product, label: 'No Price');
      }

      if (product.price < minValidPrice) {
        return AnalyzedProduct(product: product, label: 'Outlier');
      }

      String label = 'Normal';

      // Jika harga <= 90% dari nilai rata-rata (diskon >= 10% lebih murah)
      if (product.price <= averagePrice * 0.9) {
        label = 'Best Deal';
      }
      // Jika harga lebih mahal dari nilai rata-rata
      else if (product.price > averagePrice) {
        label = 'Overpriced';
      }

      return AnalyzedProduct(product: product, label: label);
    }).toList();
  }

  /// ══════════════════════════════════════════════════════════════════
  /// Simulasi Predictive Analytics — Prediksi Harga Minggu Depan
  ///
  /// Menggunakan random walk simulation sederhana untuk memprediksi
  /// kemungkinan harga produk di minggu depan.
  ///
  /// **Metode:** Random perturbation ±5% dari harga saat ini.
  ///
  /// **Formula:** predicted = current + (current × random(-0.05, +0.05))
  ///
  /// ⚠️ CATATAN: Ini adalah simulasi sederhana untuk demonstrasi.
  /// Dalam produksi, bisa diganti dengan model time-series seperti
  /// ARIMA, Prophet, atau LSTM untuk prediksi yang lebih akurat.
  ///
  /// **Parameter:**
  ///  - [currentPrice]: Harga produk saat ini.
  ///
  /// **Return:**
  ///  - Harga prediksi untuk minggu depan.
  /// ══════════════════════════════════════════════════════════════════
  double predictNextWeekPrice(double currentPrice) {
    final random = Random();

    // random.nextDouble() mengembalikan 0.0 sampai 1.0.
    // Dikalikan 0.1 → 0.0 sampai 0.1,
    // Dikurangi 0.05 → -0.05 hingga +0.05 (artinya +/- 5%)
    final percentageChange = (random.nextDouble() * 0.1) - 0.05;

    final predictedPrice = currentPrice + (currentPrice * percentageChange);
    return predictedPrice;
  }

  /// ══════════════════════════════════════════════════════════════════
  /// analyzeMarketPrice — Analisis mendalam untuk rekomendasi belanja.
  ///
  /// Fungsi ini melakukan tiga hal:
  ///  1. Menghitung harga rata-rata dari daftar produk.
  ///  2. Mencari harga terendah di pasar saat ini.
  ///  3. Memberikan rekomendasi strategis berdasarkan perbandingan harga
  ///     produk pilihan dengan rata-rata pasar.
  ///
  /// **Parameter:**
  ///  - [products]: Daftar produk hasil pencarian.
  ///  - [selectedProduct]: Produk yang sedang dilihat/dipilih oleh user.
  ///
  /// **Return:**
  ///  Map berisi 'average', 'minPrice', dan 'recommendation'.
  /// ══════════════════════════════════════════════════════════════════
  Map<String, dynamic> analyzeMarketPrice(
      List<Product> products, Product selectedProduct) {
    if (products.isEmpty) {
      return {
        'average': 0.0,
        'minPrice': 0.0,
        'recommendation': 'Tidak ada data',
        'diffPercent': 0.0,
      };
    }

    // 1. Menghitung harga rata-rata
    final validProducts = products.where((p) => p.price > 0).toList();
    if (validProducts.isEmpty) {
      return {
        'average': 0.0,
        'minPrice': 0.0,
        'recommendation': 'Data harga tidak tersedia',
        'diffPercent': 0.0,
      };
    }

    // 1.5. Outlier Detection (Hapus Aksesori/Barang Palsu)
    final sortedPrices = validProducts.map((p) => p.price).toList()..sort();
    final middle = sortedPrices.length ~/ 2;
    double median;
    if (sortedPrices.length % 2 == 1) {
      median = sortedPrices[middle];
    } else {
      median = (sortedPrices[middle - 1] + sortedPrices[middle]) / 2.0;
    }
    
    final minValidPrice = median * 0.5;
    final filteredProducts = validProducts.where((p) => p.price >= minValidPrice).toList();
    
    if (filteredProducts.isEmpty) {
      return {
        'average': 0.0,
        'minPrice': 0.0,
        'recommendation': 'Data harga tidak tersedia',
        'diffPercent': 0.0,
      };
    }

    final total = filteredProducts.fold(0.0, (sum, item) => sum + item.price);
    final average = total / filteredProducts.length;

    // 2. Mencari harga terendah (menggunakan filteredProducts)
    final minPrice =
        filteredProducts.map((p) => p.price).reduce((a, b) => a < b ? a : b);

    // 3. Memberikan rekomendasi
    String recommendation = 'Harga Wajar';
    double diffPercent = 0.0;

    if (average > 0) {
      diffPercent = ((selectedProduct.price - average) / average) * 100;
    }

    // Jika di bawah rata-rata sebesar 10%
    if (selectedProduct.price <= (average * 0.9)) {
      recommendation = 'Waktu Terbaik Membeli!';
    }
    // Jika di atas rata-rata
    else if (selectedProduct.price > average) {
      recommendation = 'Tunggu Harga Turun';
    } else {
      recommendation = 'Harga Stabil (Sesuai pasar)';
    }

    return {
      'average': average,
      'minPrice': minPrice,
      'recommendation': recommendation,
      'diffPercent': diffPercent,
    };
  }
}
