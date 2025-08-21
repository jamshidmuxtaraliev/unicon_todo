import 'package:flutter/material.dart';

class AppTheme {
  // Boshiy rang (yoqimli GREEN)
  static const Color primary = Color(0xFF0FA44F); // istasangiz o'zgartiring
  static const Color scaffoldBg = Colors.white;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBg,

      // AppBar: GREEN fon, oq matn
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // TabBar: to‘liq tab kengligida indikator; selected = GREEN
      tabBarTheme: const TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: Colors.black54,

        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 3),
          insets: EdgeInsets.zero, // ← to‘liq width
        ),
      ),

      // FAB ham GREEN
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
