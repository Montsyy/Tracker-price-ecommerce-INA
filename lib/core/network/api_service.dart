import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/product/data/models/product_model.dart';

class ApiService {
  /// Mengambil data products dari Google Shopping via SerpApi
  Future<List<Product>> fetchProducts(String query) async {
    // Pastikan API Key di-load dari file .env
    final apiKey = dotenv.env['SERPAPI_KEY'];
    if (apiKey == null) {
      throw Exception('API Key tidak ditemukan di dalam konfigurasi .env');
    }

    final url = Uri.parse(
        'https://serpapi.com/search.json?engine=google_shopping&q=$query&api_key=$apiKey&gl=id&hl=id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Google Shopping via SerpApi biasanya mereturn list barang di properti 'shopping_results'
        if (data['shopping_results'] != null) {
          final List<dynamic> results = data['shopping_results'];

          return results.map((item) => Product.fromJson(item)).toList();
        } else {
          return []; // Mengembalikan list kosong jika response tidak memiliki 'shopping_results'
        }
      } else {
        throw Exception(
            'Gagal memuat produk. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memanggil API: $e');
    }
  }
}
