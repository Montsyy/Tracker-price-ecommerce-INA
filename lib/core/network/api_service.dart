import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/product/data/models/product_model.dart';

class ApiService {
  /// Mengambil data products dari Google Shopping via SerpApi
  Future<List<Product>> fetchProducts(String query) async {
    // Pastikan API Key di-load dari file .env
    final apiKey = dotenv.env['SERPAPI_KEY'];
    if (apiKey == null || apiKey == '[YOUR_KEY]' || apiKey.isEmpty) {
      throw 'API Key SerpApi belum dikonfigurasi. Silakan atur SERPAPI_KEY di file .env Anda.';
    }

    final url = Uri.parse(
        'https://serpapi.com/search.json?engine=google_shopping&q=$query&api_key=$apiKey&gl=id&hl=id');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<Product> products = [];

        // Gabungkan 'inline_shopping_results' (biasanya iklan/featured)
        // dan 'shopping_results' (hasil pencarian utama)
        if (data['inline_shopping_results'] != null) {
          final List<dynamic> inlineResults = data['inline_shopping_results'];
          products.addAll(inlineResults.map((item) => Product.fromJson(item)));
        }

        if (data['shopping_results'] != null) {
          final List<dynamic> shoppingResults = data['shopping_results'];
          products
              .addAll(shoppingResults.map((item) => Product.fromJson(item)));
        }

        if (products.isEmpty) {
          throw 'Produk tidak ditemukan. Coba gunakan kata kunci pencarian lain.';
        }

        final filteredProducts = _filterProducts(products, query);

        if (filteredProducts.isEmpty) {
          throw 'Produk tidak ditemukan setelah difilter. Coba gunakan kata kunci pencarian lain.';
        }

        return filteredProducts;
      } else if (response.statusCode == 401) {
        throw 'API Key tidak valid atau tidak diizinkan. Periksa kembali SERPAPI_KEY Anda.';
      } else if (response.statusCode == 403) {
        throw 'Akses dibatasi. Mungkin kuota API Anda telah habis.';
      } else if (response.statusCode == 429) {
        throw 'Terlalu banyak permintaan. Silakan coba lagi beberapa saat lagi.';
      } else {
        throw 'Gagal mengambil data (Status: ${response.statusCode}). Silakan coba lagi.';
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet. Periksa koneksi Wi-Fi atau data seluler Anda.';
    } on http.ClientException {
      throw 'Gagal terhubung ke server. Silakan coba lagi.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Terjadi kesalahan tidak terduga: $e';
    }
  }

  /// Fungsi untuk memfilter hasil pencarian agar lebih akurat pada unit utamanya saja
  List<Product> _filterProducts(List<Product> products, String query) {
    final excludedKeywords = [
      'bekas',
      'second',
      'preloved',
      'case',
      'dus',
      'box saja',
    ];

    return products.where((product) {
      final titleLower = product.title.toLowerCase();

      // 1. Cek keyword terlarang
      if (excludedKeywords.any((keyword) => titleLower.contains(keyword))) {
        return false;
      }

      return true;
    }).toList();
  }
}
