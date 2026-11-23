# UDITflix · Vídeos y juegos en un solo lugar

Aplicación Flutter de streaming que reúne un **catálogo de películas y series** y una **tienda de juegos (UDIT Arcade)**.

Partiendo del proyecto inicial (una lista de contenidos, una ficha y un reproductor provisional), la aplicación se ha evolucionado sin reconstruirla desde cero. Sigue el documento de diseño propio `UDITFLIX_Diseno_Responsive.pdf`, que define tres formatos: escritorio, tablet y móvil.

---

## Funcionalidades

### Catálogo visual
- Portadas de películas y series cargadas desde Internet.
- Carrusel de **destacados y recomendados**.
- **Especiales de la semana**.
- Lista con pestañas **Novedades / Más populares / Juegos gratis** y panel de detalle.
- **Explorar por categoría**: Acción, Ciencia ficción, Terror, Documental, Comedia, Deportes y Juegos.
- Pantalla **Videos** con rejilla de tarjetas, filtros por categoría, valoración, edad, año, duración y barra de progreso.
- **Ficha** de cada contenido con portada, valoración, etiquetas, descripción y botón **Reproducir**.
- **Buscar**: filtra por título o categoría.
- **Perfil**: muestra la sección "Seguir viendo".

### Reproductor de vídeo
Reproduce vídeos MP4 reales desde Internet con el paquete `video_player`.

- Reproducir y pausar.
- Retroceder y avanzar 10 segundos.
- Barra de progreso que se puede arrastrar.
- Tiempo actual y duración total.
- Silenciar y activar el sonido.
- **Pantalla completa** en horizontal y sin barras del sistema. El botón "atrás" sale de la pantalla completa.
- Los controles se ocultan solos a los 3 segundos y vuelven a aparecer al tocar el vídeo.
- Indicador de carga y mensaje de error con botón **Reintentar** si no hay conexión.

Se accede desde **Videos → película → REPRODUCIR**.

### UDIT Arcade (sección Juegos)
- **Tres en Raya Neón**: juego destacado que se juega en la propia tienda ("Juega aquí mismo") contra la CPU. Lleva marcador de victorias, empates y derrotas y un botón **Nueva partida**. La CPU gana si puede, bloquea al jugador y, si no, prefiere el centro y las esquinas.
- **Neon Flap**: videojuego 2D al estilo Flappy Bird hecho con **Flame**. Se explica en la sección siguiente.
- Ranking de juegos con filtros por categoría. Los juegos que aún no están disponibles muestran **PRÓXIMAMENTE**.

### Neon Flap (videojuego 2D con Flame)
| Requisito | Cómo se cumple |
|---|---|
| Personaje que se mueve | Bola de neón con gravedad; flota mientras espera a que empiece la partida |
| Control por pulsaciones | Cada toque en la pantalla lo impulsa hacia arriba |
| Obstáculos que se desplazan | Parejas de columnas azules que avanzan de derecha a izquierda |
| Detección de colisiones | Hitboxes de Flame (`CircleHitbox` y `RectangleHitbox`); el suelo también cuenta |
| Puntuación | +1 por cada columna superada; también se guarda la mejor marca |
| Game Over | Pantalla con la puntuación y la mejor marca |
| Reinicio | Botón **REINICIAR** |

El marcador, el mensaje de inicio y el Game Over son *overlays* de Flutter que se dibujan encima del juego.

Se accede desde **Juegos → Neon Flap → JUGAR**. También desde el carrusel de Inicio o desde "Especiales de la semana".

---

## Diseño responsive

La misma identidad en todos los formatos: negro profundo, acentos rojo y azul neón y titulares en mayúsculas. Lo que cambia es la disposición.

| | Escritorio (≥ 1100 px) | Tablet (700–1100 px) | Móvil (< 700 px) |
|---|---|---|---|
| Navegación | Cabecera con Inicio, Videos, Juegos y buscador | Cabecera | Barra inferior con 5 accesos |
| Categorías en Inicio | Menú lateral | Fila de chips | Fila de chips con scroll horizontal |
| Carrusel | Imagen e información en dos columnas | Panel de información más estrecho | Imagen arriba, información abajo |
| Lista de Inicio | Lista y detalle lado a lado | Lista y detalle lado a lado | Lista compacta, sin detalle |
| Rejilla de Videos y categorías | 4 columnas | 3 columnas | 2 columnas |
| Juego destacado | Imagen y tablero al 50 / 50 | Imagen y tablero al 50 / 50 | Tablero debajo de la imagen |

---

## Estructura del proyecto

```text
lib/
├── main.dart                     # Punto de entrada y tema
├── arcade/
│   └── neon_flap_game.dart       # Juego Flame: personaje, columnas, fondo y lógica
├── data/
│   └── contenidos.dart           # Películas, series, juegos y categorías
├── models/
│   ├── contenido.dart            # Película o serie
│   ├── juego.dart                # Juego de la tienda
│   └── elemento_catalogo.dart    # Envuelve un vídeo o un juego para las listas mixtas
├── screens/
│   ├── principal_screen.dart     # Navegación entre secciones
│   ├── inicio_screen.dart        # Tienda, destacados, especiales, lista y categorías
│   ├── catalogo_screen.dart      # Videos (rejilla con filtros)
│   ├── ficha_screen.dart         # Detalle de una película o serie
│   ├── reproductor_screen.dart   # Reproductor con video_player
│   ├── juegos_screen.dart        # UDIT Arcade: destacado, filtros y ranking
│   ├── neon_flap_screen.dart     # GameWidget y overlays del juego
│   ├── buscar_screen.dart
│   └── perfil_screen.dart
├── theme/
│   └── uditflix_theme.dart       # Colores, textos y tema oscuro
├── utils/
│   ├── responsive.dart           # Escritorio, tablet o móvil según el ancho
│   └── abrir.dart                # Abrir una ficha o un juego desde cualquier pantalla
└── widgets/
    ├── comunes.dart              # Logo, insignias, chips, botones, imágenes y pie
    ├── arte_neon.dart            # Portadas neón de los juegos (CustomPainter)
    ├── navegacion.dart           # Cabeceras y barra inferior
    ├── fila_elemento.dart        # Fila de las listas
    └── tres_en_raya.dart         # Tablero y lógica del Tres en Raya
```

## Paquetes añadidos

| Paquete | Uso |
|---|---|
| [`video_player`](https://pub.dev/packages/video_player) | Reproducción de vídeos MP4 |
| [`flame`](https://pub.dev/packages/flame) | Motor del videojuego 2D (bucle de juego, componentes y colisiones) |

En Android se ha añadido el permiso `INTERNET` en `AndroidManifest.xml`. Sin él, el APK de release no puede cargar imágenes ni vídeos.

---

## Ejecutar el proyecto

```bash
flutter pub get
flutter run              # en el dispositivo o emulador conectado
flutter run -d chrome    # en el navegador
```

En el navegador puedes cambiar el ancho de la ventana para ver los tres formatos.

## Verificación

```bash
flutter analyze   # sin incidencias
flutter test      # 10 pruebas
```

Qué comprueban las pruebas:
- La app se construye sin desbordamientos en escritorio (1440), tablet (834) y móvil (390), y se puede navegar a Videos y a Juegos.
- Desde Videos se abre la ficha de una película.
- La lógica del Tres en Raya detecta al ganador, y la CPU gana cuando puede y bloquea al jugador.
- En Neon Flap, la partida empieza al pulsar, sin pulsar se llega a Game Over y REINICIAR vuelve al inicio.

## Generar e instalar el APK

```bash
flutter build apk --release
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`. Hay dos formas de instalarlo:
- Con el móvil conectado por USB y la depuración USB activada, ejecuta `flutter install`.
- O copia el APK al móvil y ábrelo desde allí, autorizando la instalación desde esa fuente.

---

## Recursos utilizados

- **Vídeos de demostración** (MP4 públicos, comprobados como accesibles):
  - `flutter.github.io/assets-for-api-docs` (butterfly, bee)
  - MDN (`flower.mp4`)
  - test-videos.co.uk (Big Buck Bunny, 10 s)
- **Portadas** de películas y series: fotografías de [Unsplash](https://unsplash.com).
- **Portadas de los juegos**: dibujadas con código (`CustomPainter`), sin imágenes externas.
- **Diseño**: `UDITFLIX_Diseno_Responsive.pdf`.

> Los títulos del catálogo (Persecución Neón, Órbita Cero…) son ficticios y solo sirven de demostración.
