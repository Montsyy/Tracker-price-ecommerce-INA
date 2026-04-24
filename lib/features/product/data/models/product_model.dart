class Product {
  final String title;
  final double price;
  final String storeName;
  final String thumbnail;
  final String productUrl;
  final double rating;
  final int reviewsCount;

  Product({
    required this.title,
    required this.price,
    required this.storeName,
    required this.thumbnail,
    required this.productUrl,
    required this.rating,
    required this.reviewsCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parsing presisi berdasarkan referensi JSON SerpApi terbaru
    return Product(
      title: json['title'] ?? '',
      // Menggunakan extracted_price (int/float) untuk akurasi perhitungan
      price: _parseDouble(json['extracted_price'] ?? json['price']),
      storeName: json['source'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      productUrl: json['product_link'] ?? json['link'] ?? '',
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(json['reviews']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'extracted_price': price,
      'source': storeName,
      'thumbnail': thumbnail,
      'product_link': productUrl,
      'rating': rating,
      'reviews': reviewsCount,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Hilangkan semua karakter kecuali angka dan titik (misal: "Rp 120.000" -> "120000")
      // Namun hati-hati dengan pemisah ribuan vs desimal.
      // SerpApi extracted_price biasanya sudah angka bersih.
      // Jika memparse dari string 'price' (misal "$1,200.50"), kita perlu membersihkan koma dulu.
      final cleanValue =
          value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }
}
