import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopColors {
  static const Color primary = Color(0xFF0F67FF);
  static const Color primaryDark = Color(0xFF0B48B2);
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF6B7280);
  static const Color accent = Color(0xFFFFA41B);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF12B76A);
}

class ShopText {
  static final heading = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: ShopColors.text,
  );

  static TextStyle body([Color? color, FontWeight weight = FontWeight.w500]) {
    return GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: weight,
      color: color ?? ShopColors.text,
    );
  }

  static TextStyle caption([Color? color]) {
    return GoogleFonts.manrope(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color ?? ShopColors.muted,
    );
  }
}

class ShopShadows {
  static final soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}

class ShopButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: ShopColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14),
    elevation: 0,
  );

  static ButtonStyle ghost = OutlinedButton.styleFrom(
    foregroundColor: ShopColors.text,
    backgroundColor: Colors.transparent,
    side: const BorderSide(color: ShopColors.border),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14),
  );
}
