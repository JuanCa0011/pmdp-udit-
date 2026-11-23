
//
// MODELO CONTENIDO
//
// Esta clase representa un vídeo de nuestra plataforma UDITflix:
// una película o una serie.
//
// En programación orientada a objetos, una clase define
// qué características tendrán los objetos que creemos.
//

class Contenido {

  // Identificador único de cada contenido.
  final int id;

  // Título que aparecerá en el catálogo.
  final String titulo;

  // Descripción del contenido.
  final String descripcion;

  // Tipo de contenido: Película o Serie.
  final String tipo;

  // Duración aproximada (1h 52m, T1 · 8 ep....).
  final String duracion;

  // Categoría del catálogo (Acción, Terror...).
  final String categoria;

  // Calificación por edades (TP, 7+, 13+, 16+, 18+).
  final String edad;

  // Año de estreno.
  final int anio;

  // Porcentaje de valoración ("97% para ti").
  final int valoracion;

  // Imagen de portada cargada desde Internet.
  final String imagenUrl;

  // Vídeo MP4 de demostración que abre el reproductor.
  final String videoUrl;

  // Indica si es un estreno (insignia NUEVO / ESTRENO).
  final bool estreno;

  // Progreso de visionado entre 0 y 1 (barra roja de la tarjeta).
  final double progreso;

  // Constructor: permite crear nuevos objetos Contenido.
  const Contenido({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.duracion,
    required this.categoria,
    required this.edad,
    required this.anio,
    required this.valoracion,
    required this.imagenUrl,
    required this.videoUrl,
    this.estreno = false,
    this.progreso = 0,
  });

  // Texto de la insignia en las listas.
  String get insignia => estreno ? 'ESTRENO' : 'INCLUIDO';
}
