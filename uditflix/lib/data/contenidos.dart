
//
// DATOS SIMULADOS DE UDITFLIX
//
// En esta versión no tenemos una API ni una base de datos.
// Por eso utilizamos listas de objetos creadas manualmente.
//
// Las portadas se cargan desde Internet (Unsplash) y los vídeos
// son MP4 públicos de demostración, comprobados como accesibles.
//

import '../models/contenido.dart';
import '../models/juego.dart';

// Vídeos MP4 públicos de demostración.
const String _videoMariposa =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
const String _videoAbeja =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
const String _videoFlor =
    'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4';
const String _videoBunny =
    'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4';

// Construye la URL de una portada de Unsplash con un ancho razonable.
String _unsplash(String id) =>
    'https://images.unsplash.com/$id?w=900&q=70&auto=format&fit=crop';

// Categorías del catálogo de vídeos.
const List<String> categoriasVideo = [
  'Acción',
  'Ciencia ficción',
  'Terror',
  'Documental',
  'Comedia',
  'Deportes',
];

// Categorías de la tienda de juegos.
const List<String> categoriasJuego = [
  'Estrategia',
  'Plataformas',
  'Puzle',
  'Shooter',
  'Arcade',
  'Memoria',
];

// Catálogo de películas y series.
final List<Contenido> contenidos = [

  Contenido(
    id: 1,
    titulo: 'Persecución Neón',
    descripcion:
        'Una mensajera en moto atraviesa una ciudad de luces de neón '
        'con un paquete que medio mundo quiere recuperar antes del amanecer.',
    tipo: 'Película',
    duracion: '1h 52m',
    categoria: 'Acción',
    edad: '16+',
    anio: 2026,
    valoracion: 97,
    imagenUrl: _unsplash('photo-1558981403-c5f9899a28bc'),
    videoUrl: _videoBunny,
    estreno: true,
    progreso: 0.55,
  ),

  Contenido(
    id: 2,
    titulo: 'Órbita Cero',
    descripcion:
        'La última tripulación de una estación orbital descubre que la Tierra '
        'ha dejado de responder. Solo les quedan setenta y dos horas de oxígeno.',
    tipo: 'Película',
    duracion: '2h 08m',
    categoria: 'Ciencia ficción',
    edad: '13+',
    anio: 2026,
    valoracion: 94,
    imagenUrl: _unsplash('photo-1446776811953-b23d57bd21aa'),
    videoUrl: _videoAbeja,
    estreno: true,
  ),

  Contenido(
    id: 3,
    titulo: 'La Casa Roja',
    descripcion:
        'Una familia hereda una mansión aislada entre la niebla. '
        'Cada noche, una habitación nueva aparece en el plano de la casa.',
    tipo: 'Película',
    duracion: '1h 39m',
    categoria: 'Terror',
    edad: '18+',
    anio: 2025,
    valoracion: 88,
    imagenUrl: _unsplash('photo-1518709268805-4e9042af9f23'),
    videoUrl: _videoFlor,
    progreso: 0.2,
  ),

  Contenido(
    id: 4,
    titulo: 'Abismo Azul',
    descripcion:
        'Un viaje documental a las profundidades del océano para conocer '
        'a las criaturas que viven donde nunca llega la luz del sol.',
    tipo: 'Película',
    duracion: '48m',
    categoria: 'Documental',
    edad: 'TP',
    anio: 2025,
    valoracion: 91,
    imagenUrl: _unsplash('photo-1544551763-46a013bb70d5'),
    videoUrl: _videoMariposa,
  ),

  Contenido(
    id: 5,
    titulo: 'Cocina en Caos',
    descripcion:
        'Un chef con más ambición que talento abre un restaurante en el '
        'peor local de la ciudad. Ocho episodios de desastres deliciosos.',
    tipo: 'Serie',
    duracion: 'T1 · 8 ep.',
    categoria: 'Comedia',
    edad: '7+',
    anio: 2026,
    valoracion: 86,
    imagenUrl: _unsplash('photo-1556910103-1c02745aae4d'),
    videoUrl: _videoFlor,
    progreso: 0.8,
  ),

  Contenido(
    id: 6,
    titulo: 'Cumbre Final',
    descripcion:
        'Cuatro ciclistas de montaña se preparan para el descenso más '
        'peligroso de los Alpes en una carrera que solo puede ganar uno.',
    tipo: 'Película',
    duracion: '1h 21m',
    categoria: 'Deportes',
    edad: 'TP',
    anio: 2024,
    valoracion: 90,
    imagenUrl: _unsplash('photo-1544191696-102dbdaeeaa0'),
    videoUrl: _videoBunny,
  ),

];

// Juegos de la tienda UDIT Arcade, en orden de ranking.
const List<Juego> juegos = [

  Juego(
    id: 101,
    titulo: 'Tres en Raya Neón',
    descripcion:
        'El clásico de siempre con luces de neón. Enfréntate a la CPU '
        'directamente desde la tienda.',
    categoria: 'Estrategia',
    etiquetas: ['Clásico', '1 jugador', 'Rápido'],
    opiniones: 'Extremadamente positivas',
    jugando: '12.4K',
    arte: ArteJuego.tresEnRaya,
    destino: DestinoJuego.tresEnRaya,
  ),

  Juego(
    id: 102,
    titulo: 'Neon Flap',
    descripcion:
        'Pulsa para volar y esquiva las columnas de neón. '
        'Cada columna superada suma un punto.',
    categoria: 'Arcade',
    etiquetas: ['Arcade', 'Reflejos', '1 jugador'],
    opiniones: 'Muy positivas',
    jugando: '9.6K',
    arte: ArteJuego.neonFlap,
    destino: DestinoJuego.neonFlap,
  ),

  Juego(
    id: 103,
    titulo: 'Pixel Runner',
    descripcion: 'Corre, salta y evita los pinchos en un mundo pixel art.',
    categoria: 'Plataformas',
    etiquetas: ['Arcade', 'Pixel art'],
    opiniones: 'Muy positivas',
    jugando: '8.1K',
    arte: ArteJuego.pixelRunner,
    destino: DestinoJuego.proximamente,
  ),

  Juego(
    id: 104,
    titulo: 'Neon Blocks',
    descripcion: 'Encaja las piezas de neón y limpia las líneas.',
    categoria: 'Puzle',
    etiquetas: ['Puzle', 'Relajante'],
    opiniones: 'Muy positivas',
    jugando: '6.7K',
    arte: ArteJuego.neonBlocks,
    destino: DestinoJuego.proximamente,
  ),

  Juego(
    id: 105,
    titulo: 'Galaxy Defender',
    descripcion: 'Defiende la galaxia de oleadas de naves enemigas.',
    categoria: 'Shooter',
    etiquetas: ['Arcade', 'Retro'],
    opiniones: 'Positivas',
    jugando: '5.3K',
    arte: ArteJuego.galaxyDefender,
    destino: DestinoJuego.proximamente,
  ),

  Juego(
    id: 106,
    titulo: 'Neon Snake',
    descripcion: 'Crece sin chocar contigo mismo en una rejilla de neón.',
    categoria: 'Arcade',
    etiquetas: ['Clásico', 'Reflejos'],
    opiniones: 'Muy positivas',
    jugando: '4.9K',
    arte: ArteJuego.neonSnake,
    destino: DestinoJuego.proximamente,
  ),

  Juego(
    id: 107,
    titulo: 'Memoria Flash',
    descripcion: 'Encuentra las parejas de cartas antes de que se apaguen.',
    categoria: 'Memoria',
    etiquetas: ['Cartas', 'Familiar'],
    opiniones: 'Positivas',
    jugando: '3.2K',
    arte: ArteJuego.memoriaFlash,
    destino: DestinoJuego.proximamente,
  ),

];
