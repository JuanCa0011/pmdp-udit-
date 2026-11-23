//
// MODELO JUEGO
//
// Representa un videojuego de la tienda UDIT Arcade.
//

// Ilustración neón que se dibuja para cada juego.
enum ArteJuego {
  tresEnRaya,
  neonFlap,
  pixelRunner,
  neonBlocks,
  galaxyDefender,
  neonSnake,
  memoriaFlash,
}

// Qué ocurre al pulsar JUGAR.
enum DestinoJuego {
  // Se juega dentro de la tienda (panel "Juega aquí mismo").
  tresEnRaya,

  // Abre el videojuego 2D de UDIT Arcade hecho con Flame.
  neonFlap,

  // Todavía no está disponible.
  proximamente,
}

class Juego {
  final int id;
  final String titulo;
  final String descripcion;

  // Categoría de la tienda (Estrategia, Arcade, Puzle...).
  final String categoria;

  // Etiquetas cortas (Clásico, 1 jugador, Rápido...).
  final List<String> etiquetas;

  // Opinión de los jugadores (Muy positivas...).
  final String opiniones;

  // Jugadores activos (12.4K).
  final String jugando;

  final ArteJuego arte;
  final DestinoJuego destino;

  const Juego({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.etiquetas,
    required this.opiniones,
    required this.jugando,
    required this.arte,
    required this.destino,
  });

  bool get jugable => destino != DestinoJuego.proximamente;
}
