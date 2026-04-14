class Product {
  final String title;
  final double price;
  final String storeName;
  final String thumbnail;
  final String productUrl;
  final double rating;

  Product({
    required this.title,
    required this.price,
    required this.storeName,
    required this.thumbnail,
    required this.productUrl,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parsing berdasarkan referensi data Google Shopping API
    return Product(
      title: json['title'] ?? '',
      // Konversi secara aman ke double
      price: _parseDouble(json['price']),
      storeName: json['source'] ?? json['store_name'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      productUrl: json['link'] ?? json['product_url'] ?? '',
      rating: _parseDouble(json['rating']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'storeName': storeName,
      'thumbnail': thumbnail,
      'productUrl': productUrl,
      'rating': rating,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
