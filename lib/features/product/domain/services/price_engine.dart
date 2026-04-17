import '../../data/models/product_model.dart';

/// ══════════════════════════════════════════════════════════════════════
/// PriceEngine — Otak di balik analisis harga belanja.
///
/// Bertanggung jawab untuk mengolah data mentah dari SerpApi dan menentukan
/// apakah sebuah produk merupakan penawaran yang baik (Good Deal) atau tidak.
/// ══════════════════════════════════════════════════════════════════════
class PriceEngine {
  /// Menghitung rata-rata harga dari daftar produk (shopping_results).
  static double calculateAverage(List<Product> products) {
    if (products.isEmpty) return 0.0;
    
    final validPrices = products
        .where((p) => p.price > 0)
        .map((p) => p.price)
        .toList();
    
    if (validPrices.isEmpty) return 0.0;
    
    final sum = validPrices.reduce((a, b) => a + b);
    return sum / validPrices.length;
  }

  /// Membandingkan harga produk yang dipilih dengan rata-rata pasar.
  /// Mengembalikan 'Good Deal' jika harga di bawah rata-rata.
  static String evaluateProduct(Product selectedProduct, List<Product> products) {
    if (selectedProduct.price == 0) return 'Data Harga Tidak Lengkap';
    
    final average = calculateAverage(products);
    if (average == 0) return 'Data Pasar Tidak Cukup';

    if (selectedProduct.price < average) {
      return 'Good Deal';
    } else {
      return 'Harga Pasar';
    }
  }

  /// Menentukan status deal dengan pesan yang lebih deskriptif.
  /// ══════════════════════════════════════════════════════════════════
  /// getSmartRecommendation — Analisis berbasis Median Price.
  ///
  /// Berbeda dengan rata-rata, median lebih tahan terhadap harga ekstrem.
  /// Memberikan label dan alasan logis berdasarkan threshold 5%.
  /// ══════════════════════════════════════════════════════════════════
  static Map<String, dynamic> getSmartRecommendation(
      List<Product> products, Product selectedProduct) {
    if (products.isEmpty || selectedProduct.price == 0) {
      return {
        'label': 'Data Tidak Cukup',
        'color': 'gray',
        'reason': 'Belum ada data harga pasar yang valid untuk dibandingkan.'
      };
    }

    // 1. Hitung Median
    final prices =
        products.where((p) => p.price > 0).map((p) => p.price).toList();
    if (prices.isEmpty) return {'label': 'Data Kosong', 'color': 'gray'};
    prices.sort();

    double median;
    int middle = prices.length ~/ 2;
    if (prices.length % 2 == 1) {
      median = prices[middle];
    } else {
      median = (prices[middle - 1] + prices[middle]) / 2.0;
    }

    // 2. Evaluasi berdasarkan Threshold 5%
    final lowerBound = median * 0.95;
    final upperBound = median * 1.05;

    if (selectedProduct.price < lowerBound) {
      final diff = ((median - selectedProduct.price) / median * 100).round();
      return {
        'label': 'Sangat Murah (Beli!)',
        'color': 'green',
        'reason':
            'Harga ini $diff% di bawah nilai tengah pasar. Penawaran yang sangat menguntungkan!'
      };
    } else if (selectedProduct.price > upperBound) {
      final diff = ((selectedProduct.price - median) / median * 100).round();
      return {
        'label': 'Mahal (Tunggu)',
        'color': 'red',
        'reason':
            'Harga terdeteksi $diff% lebih mahal dari median pasar. Sebaiknya Anda menunggu harga turun.'
      };
    } else {
      return {
        'label': 'Harga Normal',
        'color': 'yellow',
        'reason':
            'Harga produk ini mencerminkan nilai pasar yang wajar saat ini.'
      };
    }
  }
}
