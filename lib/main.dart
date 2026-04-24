import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/providers/cart_provider.dart';
import 'features/product/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat variabel environment dari file .env
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

/// Root widget aplikasi Smart Price Tracker.
///
/// Menggunakan design system "The Financial Atelier" dari Stitch:
///  - Primary: Deep Teal (#27676E)
///  - Background: Off-white (#F8FAFA)
///  - Font: Inter (via GoogleFonts)
///  - Material 3
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ── Design System Tokens ──
  static const Color _primary = Color(0xFF27676E);
  static const Color _background = Color(0xFFF8FAFA);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Smart Price Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Menggunakan GoogleFonts.inter sebagai default font global
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: _primary,
            brightness: Brightness.light,
            surface: _background,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: _background,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
