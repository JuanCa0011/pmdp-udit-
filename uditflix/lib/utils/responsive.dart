//
// UTILIDADES RESPONSIVE
//
// El diseño define tres formatos de referencia:
// escritorio (1440 px), tablet (834 px) y móvil (390 px).
// Aquí decidimos en cuál estamos según el ancho disponible.
//

import 'package:flutter/widgets.dart';

enum Formato { movil, tablet, escritorio }

class Responsive {
  Responsive._();

  // A partir de este ancho usamos la disposición de tablet.
  static const double anchoTablet = 700;

  // A partir de este ancho usamos la disposición de escritorio.
  static const double anchoEscritorio = 1100;

  static Formato de(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    if (ancho >= anchoEscritorio) return Formato.escritorio;
    if (ancho >= anchoTablet) return Formato.tablet;
    return Formato.movil;
  }

  // Número de columnas de las rejillas: 4 / 3 / 2.
  static int columnas(Formato formato) {
    switch (formato) {
      case Formato.escritorio:
        return 4;
      case Formato.tablet:
        return 3;
      case Formato.movil:
        return 2;
    }
  }

  // Margen lateral del contenido.
  static double margen(Formato formato) => formato == Formato.movil ? 16 : 24;
}
