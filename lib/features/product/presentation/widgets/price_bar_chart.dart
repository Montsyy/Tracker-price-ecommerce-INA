import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/product_model.dart';

/// ══════════════════════════════════════════════════════════════════════
/// PriceBarChart — Visualisasi perbandingan harga berbasis Bar Chart.
///
/// Dirancang untuk kebutuhan presentasi (Pitching):
///  - Sumbu X: Nama Marketplace (source).
///  - Sumbu Y: Harga (extracted_price).
///  - Highlight: Toko termurah diberi warna Hijau Terang (#00E676).
/// ══════════════════════════════════════════════════════════════════════
class PriceBarChart extends StatelessWidget {
  final List<Product> products;

  const PriceBarChart({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Ambil 5 toko pertama dengan harga valid
    final displayProducts = products
        .where((p) => p.price > 0)
        .take(5)
        .toList();

    if (displayProducts.isEmpty) return const SizedBox.shrink();

    // 2. Cari harga terendah untuk highlighting
    final double minPrice = displayProducts
        .map((p) => p.price)
        .reduce((a, b) => a < b ? a : b);

    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A3435).withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Comparison',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27676E),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (displayProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b) * 1.2),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF27676E),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${displayProducts[groupIndex].storeName}\n',
                          GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Rp${rod.toY.round()}',
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w400),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= displayProducts.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              displayProducts[index].storeName,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF566162),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: displayProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final isLowest = product.price == minPrice;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: product.price,
                          color: isLowest ? const Color(0xFF00E676) : const Color(0xFF27676E).withValues(alpha: 0.8),
                          width: 22,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (displayProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b) * 1.2),
                            color: const Color(0xFFF0F4F5),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
