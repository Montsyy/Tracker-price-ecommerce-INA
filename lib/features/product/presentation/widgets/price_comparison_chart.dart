import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/product_model.dart';

/// ══════════════════════════════════════════════════════════════════════
/// PriceComparisonChart — Widget visualisasi perbandingan harga pasar.
///
/// Menampilkan grafik batang (Bar Chart) untuk 5 toko pertama dari hasil
/// pencarian SerpApi. Memberikan indikator visual instan:
///  - HIJAU (#3D9F64): Menandakan harga termurah (Best Value).
///  - MERAH (#9F403D): Menandakan harga termahal dalam sampel.
///  - TEAL MUDA (#DAE5E6): Harga antara (Normal).
/// ══════════════════════════════════════════════════════════════════════
class PriceComparisonChart extends StatelessWidget {
  /// Daftar produk hasil fetch dari API.
  final List<Product> products;

  const PriceComparisonChart({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Ambil 5 toko unik pertama dengan harga yang valid (> 0)
    final Map<String, Product> uniqueStores = {};
    for (var p in products) {
      if (p.price > 0 && !uniqueStores.containsKey(p.storeName)) {
        uniqueStores[p.storeName] = p;
      }
      if (uniqueStores.length >= 5) break;
    }

    final topProducts = uniqueStores.values.toList();

    // Jika data tidak cukup untuk ditampilkan
    if (topProducts.isEmpty) return const SizedBox.shrink();

    // 2. Tentukan harga ekstrim (min & max) untuk pewarnaan batang
    final validPrices = topProducts.map((p) => p.price).toList();
    final double minPrice = validPrices.reduce((a, b) => a < b ? a : b);
    final double maxPrice = validPrices.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A3435).withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Section ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Comparison',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF27676E),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Perbandingan 5 toko penyedia',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF566162).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF27676E),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Bar Chart Row ──
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: topProducts.map((p) {
                // Kalkulasi rasio tinggi batang terhadap harga tertinggi
                // Rasio minimal 0.2 agar batang tidak terlalu pendek
                final double ratio = maxPrice > 0 ? (p.price / maxPrice) : 0.0;

                // Pewarnaan logis sesuai permintaan user
                Color barColor = const Color(0xFFDAE5E6); // Default
                if (p.price == minPrice) {
                  barColor = const Color(0xFF3D9F64); // Termurah (Hijau)
                } else if (p.price == maxPrice) {
                  barColor = const Color(0xFF9F403D); // Termahal (Merah)
                }

                return _buildBarItem(p.storeName, p.price, ratio, barColor);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk membangun satu item batang grafik
  Widget _buildBarItem(String store, double price, double ratio, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Label Harga (Sederhana: dalam ribuan/jutaan)
          Text(
            _compactPrice(price),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),

          // Batang Grafik dengan Animasi Sederhana via Container
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: ratio.clamp(0.15, 1.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                      bottom: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Label Nama Toko
          SizedBox(
            height: 32,
            child: Text(
              store,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF566162),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mengubah harga menjadi format ringkas (K/M) untuk label grafik
  String _compactPrice(double price) {
    if (price >= 1000000) {
      return 'Rp${(price / 1000000).toStringAsFixed(1)}jt';
    } else if (price >= 1000) {
      return 'Rp${(price / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp${price.toStringAsFixed(0)}';
  }
}
