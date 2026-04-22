class AiAdvisor {
  static String getReliabilityLabel(double rating, int reviews) {
    if (rating >= 4.5 && reviews > 100) {
      return 'Toko Sangat Terpercaya';
    }
    if (rating >= 4.0 && reviews > 20) {
      return 'Toko Rekomendasi';
    }
    if (reviews < 5) {
      return 'Ulasan Sedikit (Hati-hati)';
    }
    return 'Standar';
  }
}
