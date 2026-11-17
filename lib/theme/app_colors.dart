import 'package:flutter/material.dart';

/// Paleta única de la app (tomada de las variables CSS de la versión web).
/// Ningún widget debe usar colores "sueltos": todo sale de aquí.
class AppColors {
  AppColors._();

  // Superficies
  static const bg = Color(0xFF0C0D10);
  static const raised = Color(0xFF101114);
  static const panel = Color(0xFF16181D);
  static const panel2 = Color(0xFF1C1F26);
  static const panel3 = Color(0xFF242833);
  static const line = Color(0xFF262A33);
  static const lineStrong = Color(0xFF333844);

  // Texto
  static const text = Color(0xFFF2F4F7);
  static const textDim = Color(0xFF9BA3B4);
  static const textFaint = Color(0xFF6A7382);

  // Acentos
  static const blue = Color(0xFF6D8BFF);
  static const gold = Color(0xFFC9A24B);
  static const green = Color(0xFF3FC77F);
  static const red = Color(0xFFE06A52);
  static const amber = Color(0xFFE0A73F);
  static const purple = Color(0xFF8B7BF0);

  // Fondos suaves (acento con transparencia)
  static const blueSoft = Color(0xFF1A1F33);
  static const goldSoft = Color(0x24C9A24B);
  static const greenSoft = Color(0x1F3FC77F);
  static const redSoft = Color(0x21E06A52);
  static const amberSoft = Color(0x21E0A73F);
}
