//
// ELEMENTO DEL CATÁLOGO
//
// Las listas de Inicio y de Buscar mezclan vídeos y juegos.
// Esta clase envuelve uno u otro y ofrece los textos comunes.
//

import 'contenido.dart';
import 'juego.dart';

class ElementoCatalogo {
  final Contenido? contenido;
  final Juego? juego;

  const ElementoCatalogo.video(Contenido this.contenido) : juego = null;

  const ElementoCatalogo.juego(Juego this.juego) : contenido = null;

  bool get esJuego => juego != null;

  String get titulo => contenido?.titulo ?? juego!.titulo;

  String get descripcion => contenido?.descripcion ?? juego!.descripcion;

  // "Película · Acción, 16+, 2026" o "Juego · Estrategia, Clásico".
  String get subtitulo {
    final c = contenido;
    if (c != null) {
      return '${c.tipo} · ${c.categoria}, ${c.edad}, ${c.anio}';
    }
    final j = juego!;
    return 'Juego · ${[j.categoria, ...j.etiquetas.take(2)].join(', ')}';
  }

  String get insignia => contenido?.insignia ?? 'GRATIS';

  String get valoracion =>
      contenido != null ? '${contenido!.valoracion}% para ti' : juego!.opiniones;

  List<String> get etiquetas {
    final c = contenido;
    if (c != null) return [c.categoria, c.edad, '${c.anio}'];
    return juego!.etiquetas;
  }

  // Duración del vídeo o jugadores activos del juego.
  String get detalle =>
      contenido?.duracion ?? '${juego!.jugando} jugando';
}
