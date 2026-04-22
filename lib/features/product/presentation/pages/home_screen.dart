import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_service.dart';
import '../../domain/services/ai_advisor.dart';
import '../../domain/usecases/price_analyzer.dart';
import '../widgets/price_comparison_chart.dart';

/// ══════════════════════════════════════════════════════════════════════
/// HomeScreen — Tampilan utama aplikasi Smart Price Tracker.
///
/// Layar ini menampilkan:
///  1. Search TextField untuk mencari produk via Google Shopping API.
///  2. ListView.builder yang merender hasil produk sebagai Card.
///  3. Setiap Card menampilkan gambar, harga, nama toko, dan badge
///     hasil analisis AI (Best Deal / Overpriced / Normal).
///  4. CircularProgressIndicator saat data sedang di-fetch dari API.
///
/// Design System: "The Financial Atelier" — minimalis, editorial,
/// menggunakan Deep Teal (#27676E) sebagai warna primer,
/// font Inter via GoogleFonts, dan prinsip "No-Line" (tanpa border).
/// ══════════════════════════════════════════════════════════════════════
enum SortOption { bestDeals, lowestPrice, highestPrice, highestRating, mostReviews }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Controllers & Services ──
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final PriceAnalyzer _priceAnalyzer = PriceAnalyzer();

  // ── State ──
  List<AnalyzedProduct> _analyzedProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;
  SortOption _currentSort = SortOption.bestDeals;

  List<AnalyzedProduct> get _sortedProducts {
    final List<AnalyzedProduct> list = List.from(_analyzedProducts);

    switch (_currentSort) {
      case SortOption.lowestPrice:
        list.sort((a, b) {
          if (a.product.price == 0) return 1;
          if (b.product.price == 0) return -1;
          return a.product.price.compareTo(b.product.price);
        });
        break;
      case SortOption.highestPrice:
        list.sort((a, b) => b.product.price.compareTo(a.product.price));
        break;
      case SortOption.highestRating:
        list.sort((a, b) => b.product.rating.compareTo(a.product.rating));
        break;
      case SortOption.mostReviews:
        list.sort((a, b) => b.product.reviewsCount.compareTo(a.product.reviewsCount));
        break;
      case SortOption.bestDeals:
        list.sort((a, b) {
          int score(String label) {
            if (label == 'Best Deal') return 3;
            if (label == 'Normal') return 2;
            if (label == 'Overpriced') return 1;
            return 0;
          }

          final aScore = score(a.label);
          final bScore = score(b.label);

          if (aScore != bScore) {
            return bScore.compareTo(aScore);
          } else {
            if (a.product.price == 0) return 1;
            if (b.product.price == 0) return -1;
            return a.product.price.compareTo(b.product.price);
          }
        });
        break;
    }
    return list;
  }

  // ══════════════════════════════════════════════════════════════════
  //  DESIGN SYSTEM TOKENS — "The Financial Atelier" (Stitch)
  //
  //  Palet warna diambil dari design system Stitch project
  //  "Minimalist Price Tracker App". Warna disusun berdasarkan
  //  Material 3 tonal palette dengan primary Deep Teal.
  // ══════════════════════════════════════════════════════════════════
  static const Color _primary = Color(0xFF27676E);
  static const Color _primaryDim = Color(0xFF175B62);
  static const Color _background = Color(0xFFF8FAFA);
  static const Color _surfaceContainerHighest = Color(0xFFDAE5E6);
  static const Color _surfaceContainerLow = Color(0xFFF0F4F5);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF2A3435);
  static const Color _onSurfaceVariant = Color(0xFF566162);
  static const Color _error = Color(0xFF9F403D);
  static const Color _primaryContainer = Color(0xFFAFEDF5);

  // ══════════════════════════════════════════════════════════════════
  //  SEARCH — Memanggil API dan menjalankan analisis AI
  //
  //  Flow:
  //  1. User mengetik query dan menekan "search" di keyboard.
  //  2. _searchProducts dipanggil → set loading state.
  //  3. ApiService.fetchProducts() memanggil Google Shopping via SerpApi.
  //  4. Hasil mentah (List<Product>) dikirim ke PriceAnalyzer.
  //  5. PriceAnalyzer.analyzePrice() menghitung rata-rata harga dan
  //     memberikan label AI pada setiap produk.
  //  6. Hasil AnalyzedProduct ditampilkan di ListView.
  // ══════════════════════════════════════════════════════════════════
  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      // ── STEP 1: Fetch data produk dari Google Shopping API ──
      final rawProducts = await _apiService.fetchProducts(query);

      // Mengabaikan produk dengan harga di bawah 1000 agar tidak masuk analitik dan list
      final products = rawProducts.where((p) => p.price >= 1000).toList();

      // ── STEP 2: Jalankan analisis AI (statistical price analysis) ──
      // PriceAnalyzer menghitung rata-rata harga dari seluruh produk,
      // lalu memberikan label: 'Best Deal' jika harga ≤ 90% rata-rata,
      // 'Overpriced' jika harga > rata-rata, dan 'Normal' untuk sisanya.
      final analyzed = _priceAnalyzer.analyzePrice(products);

      setState(() {
        _analyzedProducts = analyzed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  /// Membuka URL produk di browser bawaan menggunakan url_launcher.
  /// Dilengkapi error handling komprehensif dengan feedback SnackBar.
  Future<void> _launchProductUrl(String url) async {
    if (url.isEmpty) {
      _showErrorSnackBar('URL produk tidak tersedia');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showErrorSnackBar('Format URL tidak valid');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showErrorSnackBar('Tidak dapat membuka URL di browser');
      }
    } catch (e) {
      _showErrorSnackBar(
        'Gagal membuka link: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  /// Helper untuk menampilkan SnackBar error yang konsisten.
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: _error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  HEADER — Branding + Search Field
  // ══════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      decoration: BoxDecoration(
        color: _background.withValues(alpha: 0.92),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── App Logo + Title ──
          Row(
            children: [
              // Gradient icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _primaryDim],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_down_rounded,
                  color: Color(0xFFE5FCFF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Tracker',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Smart Shopping Assistant',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Subtitle ──
          Text(
            'Temukan penawaran terbaik untuk produk Anda',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: _onSurfaceVariant,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 14),

          // ── Search TextField — flat style sesuai design system ──
          Container(
            decoration: BoxDecoration(
              color: _surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: _onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Cari produk, misal "iPhone 15"...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _onSurfaceVariant.withValues(alpha: 0.55),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _primary,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: _onSurfaceVariant.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _analyzedProducts = [];
                            _hasSearched = false;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _searchProducts,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  CONTENT — Loading / Error / Empty / Product List
  // ══════════════════════════════════════════════════════════════════
  Widget _buildContent() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();

    if (!_hasSearched) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Mulai Pencarian',
        subtitle: 'Ketik nama produk untuk mencari\npenawaran terbaik',
      );
    }

    if (_analyzedProducts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Tidak Ada Hasil',
        subtitle: 'Coba gunakan kata kunci yang berbeda',
      );
    }

    final displayList = _sortedProducts;

    // ── Dashboard + Result count + Product List ──
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildDashboard(_analyzedProducts),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${displayList.length} produk ditemukan',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 0.3,
                  ),
                ),
                _buildSortDropdown(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildProductCard(displayList[index]);
              },
              childCount: displayList.length,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SORT DROPDOWN
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: _surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: _currentSort,
          icon: const Icon(Icons.sort_rounded, size: 16, color: _primary),
          elevation: 4,
          isDense: true,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
          onChanged: (SortOption? newValue) {
            if (newValue != null) {
              setState(() {
                _currentSort = newValue;
              });
            }
          },
          items: const [
            DropdownMenuItem(
              value: SortOption.bestDeals,
              child: Text('Best Deals'),
            ),
            DropdownMenuItem(
              value: SortOption.lowestPrice,
              child: Text('Termurah'),
            ),
            DropdownMenuItem(
              value: SortOption.highestPrice,
              child: Text('Termahal'),
            ),
            DropdownMenuItem(
              value: SortOption.highestRating,
              child: Text('Rating Tertinggi'),
            ),
            DropdownMenuItem(
              value: SortOption.mostReviews,
              child: Text('Ulasan Terbanyak'),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  DASHBOARD (Recommendation & Chart)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildDashboard(List<AnalyzedProduct> analyzedProducts) {
    if (analyzedProducts.isEmpty) return const SizedBox.shrink();

    final products = analyzedProducts.map((e) => e.product).toList();
    final validProducts = products.where((p) => p.price > 0).toList();
    if (validProducts.isEmpty) return const SizedBox.shrink();

    // Hitung rata-rata dan temukan harga termurah untuk rekomendasi
    final minPriceProduct =
        validProducts.reduce((a, b) => a.price < b.price ? a : b);
    final marketAnalysis =
        _priceAnalyzer.analyzeMarketPrice(products, minPriceProduct);

    final String recommendation = marketAnalysis['recommendation'];
    final bool isBestDeal = recommendation.contains('Terbaik');
    final bool isWait = recommendation.contains('Tunggu');

    final Color accentColor = isBestDeal
        ? const Color(0xFF3D9F64) // Green
        : isWait
            ? _error
            : _primary;

    // Hitung Prediksi Harga
    final currentMinPrice = marketAnalysis['minPrice'] as double;
    final predictedPrice = _priceAnalyzer.predictNextWeekPrice(currentMinPrice);
    final isPriceDropping = predictedPrice < currentMinPrice;
    final predictionColor = isPriceDropping ? const Color(0xFF3D9F64) : _error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Waktu Terbaik Membeli Recommendation ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBestDeal
                        ? Icons.auto_awesome
                        : isWait
                            ? Icons.timer_outlined
                            : Icons.lightbulb_outline_rounded,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisis Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Berdasarkan harga terendah ${_formatPrice(marketAnalysis['minPrice'])}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Prediksi Harga (Predictive Analytics) ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: predictionColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: predictionColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: predictionColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPriceDropping
                        ? Icons.trending_down_rounded
                        : Icons.trending_up_rounded,
                    color: predictionColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prediksi Harga (Bulan Depan)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPriceDropping
                            ? 'Harga Diprediksi Turun'
                            : 'Harga Diprediksi Naik',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: predictionColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Prediksi: ${_formatPrice(predictedPrice)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // ── Grafik Perbandingan Harga ──
          PriceComparisonChart(
            onProductTap: _launchProductUrl,
            products: products.where((p) {
              final store = p.storeName.toLowerCase();
              return store.contains('lazada') ||
                  store.contains('shopee') ||
                  store.contains('tokopedia') ||
                  store.contains('tiktok') ||
                  store.contains('blibli');
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  LOADING STATE
  // ══════════════════════════════════════════════════════════════════
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mencari produk...',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Menganalisis harga terbaik untuk Anda',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  ERROR STATE
  // ══════════════════════════════════════════════════════════════════
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: _error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            // Retry button
            TextButton.icon(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _searchProducts(_searchController.text);
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(foregroundColor: _primary),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ══════════════════════════════════════════════════════════════════
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: _primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  PRODUCT CARD — Image · Title · Price · Store · AI Badge
  //
  //  Setiap Card menampilkan data produk hasil dari Google Shopping
  //  API dan badge label dari PriceAnalyzer. Badge ini merupakan
  //  output dari "AI" analisis harga yang membandingkan harga
  //  masing-masing produk terhadap rata-rata harga seluruh hasil.
  // ══════════════════════════════════════════════════════════════════
  Widget _buildProductCard(AnalyzedProduct analyzed) {
    final product = analyzed.product;
    final label = analyzed.label;

    return GestureDetector(
      onTap: () => _launchProductUrl(product.productUrl),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          // Ambient shadow — prinsip "felt, not seen" dari design system
          boxShadow: [
            BoxShadow(
              color: _onSurface.withValues(alpha: 0.04),
              blurRadius: 32,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product Thumbnail ──
              _buildThumbnail(product.thumbnail),
              const SizedBox(width: 16),

              // ── Product Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Toko — Label-SM style (all-caps, letter-spacing)
                    Text(
                      product.storeName.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant.withValues(alpha: 0.65),
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Nama Produk
                    Text(
                      product.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _onSurface,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Harga & Rating (di samping harga)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          _formatPrice(product.price),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (product.rating > 0 || product.reviewsCount > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.reviewsCount} ulasan)',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── AI Analysis Badge & Reliability Badge ──
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildBadge(label),
                        _buildBadge(AiAdvisor.getReliabilityLabel(
                            product.rating, product.reviewsCount)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  PRODUCT THUMBNAIL
  // ══════════════════════════════════════════════════════════════════
  Widget _buildThumbnail(String thumbnailUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        height: 88,
        color: _surfaceContainerLow,
        child: thumbnailUrl.isNotEmpty
            ? Image.network(
                thumbnailUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: _onSurfaceVariant.withValues(alpha: 0.35),
                      size: 26,
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: _onSurfaceVariant.withValues(alpha: 0.35),
                  size: 26,
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  AI ANALYSIS BADGE
  //
  //  Badge ini adalah representasi visual dari output PriceAnalyzer.
  //  Warna dan ikon dipilih berdasarkan label:
  //   • "Best Deal"   → Teal (primaryContainer) + ikon api
  //   • "Overpriced"  → Merah lembut (error) + ikon trending up
  //   • "Normal"      → Abu-abu netral + ikon centang
  //   • Default       → Abu-abu + ikon tanda tanya
  //
  //  Ini memudahkan user mengidentifikasi penawaran terbaik
  //  secara visual tanpa harus membandingkan harga secara manual.
  // ══════════════════════════════════════════════════════════════════
  Widget _buildBadge(String label) {
    final (Color bg, Color text, IconData icon) = switch (label) {
      'Best Deal' => (
          _primaryContainer,
          _primaryDim,
          Icons.local_fire_department_rounded
        ),
      'Overpriced' => (
          _error.withValues(alpha: 0.12),
          _error,
          Icons.trending_up_rounded
        ),
      'Normal' => (
          _surfaceContainerHighest.withValues(alpha: 0.5),
          _onSurfaceVariant,
          Icons.check_circle_outline_rounded
        ),
      'Toko Sangat Terpercaya' => (
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
          Icons.verified_user_rounded
        ),
      'Toko Rekomendasi' => (
          const Color(0xFFFFF8E1),
          const Color(0xFFF57F17),
          Icons.thumb_up_rounded
        ),
      'Ulasan Sedikit (Hati-hati)' => (
          const Color(0xFFFFEBEE),
          const Color(0xFFC62828),
          Icons.warning_rounded
        ),
      'Standar' => (
          _surfaceContainerHighest.withValues(alpha: 0.5),
          _onSurfaceVariant,
          Icons.storefront_rounded
        ),
      _ => (
          _surfaceContainerHighest.withValues(alpha: 0.5),
          _onSurfaceVariant,
          Icons.help_outline_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: text,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════

  /// Format harga ke format Rupiah Indonesia (tanpa dependency intl).
  String _formatPrice(double price) {
    if (price == 0) return 'Harga tidak tersedia';
    final parts = price.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    var count = 0;
    for (var i = parts.length - 1; i >= 0; i--) {
      buffer.write(parts[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}
