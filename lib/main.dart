import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await DatabaseService.instance.initialize();
  runApp(const SecretPassApp());
}

class SecretPassApp extends StatelessWidget {
  const SecretPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecretPass',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const AuthScreen(),
    );
  }

  ThemeData _buildTheme() {
    const amber = Color(0xFFFFB300);
    const darkBg = Color(0xFF0A0A0A);
    const cardBg = Color(0xFF141414);
    const surfaceBg = Color(0xFF1C1C1C);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: amber,
        secondary: Color(0xFFFFD54F),
        surface: cardBg,
        onPrimary: Color(0xFF0A0A0A),
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: amber,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        titleLarge: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.tajawal(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: amber, width: 1.5),
        ),
        labelStyle: GoogleFonts.tajawal(color: Colors.white38),
        hintStyle: GoogleFonts.tajawal(color: Colors.white24),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: amber),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: amber,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: amber,
          foregroundColor: const Color(0xFF0A0A0A),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceBg,
        contentTextStyle: GoogleFonts.tajawal(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
