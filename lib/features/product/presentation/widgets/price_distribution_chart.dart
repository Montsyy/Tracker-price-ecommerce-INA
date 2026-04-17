import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/product_model.dart';
import '../../domain/services/price_engine.dart';

/// ══════════════════════════════════════════════════════════════════════
/// PriceDistributionChart — Visualisasi distribusi harga menggunakan fl_chart.
///
/// Menampilkan grafik garis (Line Chart) yang menunjukkan sebaran harga
/// produk di berbagai marketplace, memudahkan user melihat posisi harga
/// yang mereka pilih (selectedProduct) dibandingkan tren pasar.
/// ══════════════════════════════════════════════════════════════════════
class PriceDistributionChart extends StatelessWidget {
  final List<Product> products;
  final Product? selectedProduct;

  const PriceDistributionChart({
    super.key,
    required this.products,
    this.selectedProduct,
  });

  @override
  Widget build(BuildContext context) {
    // Filter dan urutkan harga untuk membuat distribusi
    final validProducts = products.where((p) => p.price > 0).toList();
    validProducts.sort((a, b) => a.price.compareTo(b.price));

    if (validProducts.length < 2) return const SizedBox.shrink();

    final average = PriceEngine.calculateAverage(products);

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 24, 28, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A3435).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 20),
            child: Text(
              'Distribusi Harga Pasar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27676E),
              ),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(validProducts),
                    isCurved: true,
                    color: const Color(0xFF27676E),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF27676E).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                // Tambahkan penanda untuk harga yang dipilih
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: (selectedProduct?.price ?? 0),
                      color: const Color(0xFF9F403D),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9F403D),
                        ),
                        labelResolver: (line) => 'Harga Anda',
                      ),
                    ),
                    HorizontalLine(
                      y: average,
                      color: const Color(0xFF566162),
                      strokeWidth: 1,
                      dashArray: [10, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF566162),
                        ),
                        labelResolver: (line) => 'Rata-rata',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menghasilkan titik koordinat untuk grafik (Urutan vs Harga)
  List<FlSpot> _generateSpots(List<Product> sortedProducts) {
    return List.generate(sortedProducts.length, (index) {
      return FlSpot(index.toDouble(), sortedProducts[index].price);
    });
  }
}
