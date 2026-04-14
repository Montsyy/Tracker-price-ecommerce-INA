import 'dart:math';
import '../../data/models/product_model.dart';

/// Class pembungkus data produk yang sudah dilengkapi dengan label analisa harga
class AnalyzedProduct {
  final Product product;
  final String label; // Contoh: 'Best Deal', 'Overpriced', 'Normal'

  AnalyzedProduct({
    required this.product,
    required this.label,
  });
}

class PriceAnalyzer {
  /// Fungsi untuk menghitung rata-rata dan memberikan label Best Deal / Overpriced
  List<AnalyzedProduct> analyzePrice(List<Product> products) {
    if (products.isEmpty) return [];

    // Filter produk yang harganya lebih dari 0 untuk menghindari div-by-zero yang tidak akurat
    final validProducts = products.where((p) => p.price > 0).toList();
    if (validProducts.isEmpty) {
      // Jika tidak ada data valid, berikan label unknown
      return products.map((p) => AnalyzedProduct(product: p, label: 'Unknown')).toList();
    }

    // Kalkulasi Rata-Rata Harga
    final total = validProducts.fold(0.0, (sum, item) => sum + item.price);
    final averagePrice = total / validProducts.length;

    // Proses Labeling
    return products.map((product) {
      if (product.price == 0) {
        return AnalyzedProduct(product: product, label: 'No Price');
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

  /// Simulasi Predictive Analytics: Prediksi harga minggu depan (tren acak +/- 5%)
  double predictNextWeekPrice(double currentPrice) {
    final random = Random();
    
    // random.nextDouble() mengembalikan 0.0 sampai 1.0.
    // dikalikan 0.1 jadi 0.0 sampai 0.1, dikurangi 0.05 menghasilkan -0.05 hingga +0.05 (artinya +/- 5%)
    final percentageChange = (random.nextDouble() * 0.1) - 0.05; 
    
    final predictedPrice = currentPrice + (currentPrice * percentageChange);
    return predictedPrice;
  }
}
