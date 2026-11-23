//
// TEMA VISUAL DE UDITFLIX
//
// Identidad del documento de diseño: negro profundo,
// acentos rojo y azul neón y titulares condensados en mayúsculas.
// Cambia la disposición entre formatos, no la marca.
//

import 'package:flutter/material.dart';

// Paleta de colores de la aplicación.
class UColores {
  UColores._();

  static const Color fondo = Color(0xFF000000);
  static const Color panel = Color(0xFF0A0D14);
  static const Color tarjeta = Color(0xFF0F131C);
  static const Color tarjetaClara = Color(0xFF171C27);
  static const Color seleccion = Color(0xFF15264A);
  static const Color borde = Color(0xFF1E2430);

  static const Color rojo = Color(0xFFE5192F);
  static const Color azul = Color(0xFF2563EB);
  static const Color azulClaro = Color(0xFF3B82F6);

  static const Color texto = Color(0xFFF5F6F8);
  static const Color textoSuave = Color(0xFF9AA3B2);
  static const Color textoTenue = Color(0xFF6B7280);
}

// Estilos de texto reutilizables.
class UTextos {
  UTextos._();

  // Titular condensado en mayúsculas (TRES EN RAYA NEÓN, VIDEOS...).
  // En Android usamos Roboto Condensed del sistema.
  static TextStyle titular(double tamano, {Color color = UColores.texto}) {
    return TextStyle(
      fontFamily: 'sans-serif-condensed',
      fontSize: tamano,
      fontWeight: FontWeight.w900,
      height: 1.05,
      letterSpacing: -0.4,
      color: color,
    );
  }

  // Antetítulo espaciado (CATÁLOGO, TIENDA DE JUEGOS...).
  static TextStyle antetitulo(Color color) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 3,
      color: color,
    );
  }

  static const TextStyle cuerpo = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: UColores.textoSuave,
  );

  static const TextStyle pequeno = TextStyle(
    fontSize: 11,
    color: UColores.textoSuave,
  );
}

// Tema Material oscuro con la paleta de UDITflix.
ThemeData temaUditflix() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: UColores.azul,
      brightness: Brightness.dark,
      primary: UColores.azul,
      secondary: UColores.rojo,
      surface: UColores.fondo,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: UColores.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: UColores.fondo,
      foregroundColor: UColores.texto,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: UColores.borde,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: UColores.tarjetaClara,
      contentTextStyle: TextStyle(color: UColores.texto),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
