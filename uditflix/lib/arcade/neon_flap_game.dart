//
// NEON FLAP · VIDEOJUEGO 2D DE UDIT ARCADE
//
// Juego sencillo inspirado en el género "flappy", hecho con Flame:
// - El personaje cae por la gravedad y sube al pulsar la pantalla.
// - Las columnas de neón se desplazan de derecha a izquierda.
// - Flame detecta las colisiones con hitboxes (círculo y rectángulos).
// - Cada columna superada suma un punto.
// - Al chocar se muestra la pantalla de Game Over con botón de reinicio.
//
// La interfaz (marcador, inicio, Game Over) son overlays de Flutter
// que se muestran encima del juego.
//

import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../theme/uditflix_theme.dart';

enum EstadoPartida { listo, jugando, terminada }

class NeonFlapGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // Nombres de los overlays de Flutter.
  static const String overlayMarcador = 'marcador';
  static const String overlayInicio = 'inicio';
  static const String overlayGameOver = 'gameOver';

  // Ajustes de dificultad.
  static const double velocidadColumnas = 170;
  static const double segundosEntreColumnas = 1.55;

  // Mejor puntuación mientras la app esté abierta.
  static int mejorPuntuacion = 0;

  final ValueNotifier<int> puntuacion = ValueNotifier(0);
  final math.Random _azar = math.Random();

  late final Personaje personaje;
  EstadoPartida estado = EstadoPartida.listo;
  double _tiempoDesdeColumna = 0;

  @override
  Color backgroundColor() => const Color(0xFF03050B);

  @override
  Future<void> onLoad() async {
    add(FondoNeon());
    personaje = Personaje();
    add(personaje);
  }

  // Cualquier pulsación hace aletear al personaje.
  @override
  void onTapDown(TapDownEvent event) {
    switch (estado) {
      case EstadoPartida.listo:
        estado = EstadoPartida.jugando;
        overlays.remove(overlayInicio);
        personaje.aletear();
      case EstadoPartida.jugando:
        personaje.aletear();
      case EstadoPartida.terminada:
        // Se reinicia con el botón de la pantalla de Game Over.
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (estado != EstadoPartida.jugando) return;

    // Generamos una nueva pareja de columnas cada cierto tiempo.
    _tiempoDesdeColumna += dt;
    if (_tiempoDesdeColumna >= segundosEntreColumnas) {
      _tiempoDesdeColumna = 0;
      _crearColumnas();
    }

    // Tocar el suelo también termina la partida.
    if (personaje.y + personaje.radio >= size.y - FondoNeon.alturaSuelo) {
      terminarPartida();
    }
  }

  void _crearColumnas() {
    final hueco = (size.y * 0.27).clamp(140.0, 210.0);
    final margen = hueco / 2 + 50;
    final limiteInferior = size.y - FondoNeon.alturaSuelo - margen;
    final centro = margen + _azar.nextDouble() * math.max(1, limiteInferior - margen);

    add(ParColumnas(
      posicionX: size.x + 10,
      centroHueco: centro,
      hueco: hueco,
      altoJuego: size.y,
    ));
  }

  void sumarPunto() => puntuacion.value++;

  void terminarPartida() {
    if (estado == EstadoPartida.terminada) return;
    estado = EstadoPartida.terminada;
    mejorPuntuacion = math.max(mejorPuntuacion, puntuacion.value);
    overlays.add(overlayGameOver);
  }

  // Deja el juego como al principio para jugar otra vez.
  void reiniciar() {
    children.whereType<ParColumnas>().toList().forEach(remove);
    puntuacion.value = 0;
    _tiempoDesdeColumna = 0;
    personaje.colocarInicio();
    estado = EstadoPartida.listo;
    overlays.remove(overlayGameOver);
    overlays.add(overlayInicio);
  }
}

// PERSONAJE: una bola de neón roja con ojo y pico.
class Personaje extends PositionComponent
    with HasGameReference<NeonFlapGame>, CollisionCallbacks {
  static const double gravedad = 1150;
  static const double impulso = -390;

  final double radio = 15;
  double _velocidad = 0;
  double _tiempo = 0;

  Personaje() : super(size: Vector2.all(36), anchor: Anchor.center, priority: 2);

  @override
  Future<void> onLoad() async {
    // Hitbox circular algo menor que el dibujo para que sea justo.
    add(CircleHitbox(radius: radio - 2, position: Vector2.all(18 - (radio - 2))));
    colocarInicio();
  }

  void colocarInicio() {
    position = Vector2(game.size.x * 0.3, game.size.y * 0.45);
    _velocidad = 0;
    angle = 0;
  }

  void aletear() => _velocidad = impulso;

  @override
  void update(double dt) {
    super.update(dt);
    _tiempo += dt;

    switch (game.estado) {
      case EstadoPartida.listo:
        // Flota suavemente mientras espera la primera pulsación.
        y = game.size.y * 0.45 + math.sin(_tiempo * 4) * 8;
      case EstadoPartida.jugando:
        _velocidad += gravedad * dt;
        y += _velocidad * dt;
        if (y < radio) {
          y = radio;
          _velocidad = 0;
        }
        angle = (_velocidad / 700).clamp(-0.45, 1.1);
      case EstadoPartida.terminada:
        // Cae hasta el suelo tras chocar.
        final suelo = game.size.y - FondoNeon.alturaSuelo - radio;
        if (y < suelo) {
          _velocidad += gravedad * dt;
          y = math.min(suelo, y + _velocidad * dt);
          angle = math.min(1.4, angle + dt * 4);
        }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Columna) game.terminarPartida();
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      c,
      radio * 1.7,
      Paint()
        ..color = UColores.rojo.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(c, radio, Paint()..color = UColores.rojo);
    canvas.drawCircle(c + Offset(radio * 0.35, -radio * 0.3), radio * 0.3,
        Paint()..color = Colors.white);
    canvas.drawCircle(c + Offset(radio * 0.47, -radio * 0.3), radio * 0.13,
        Paint()..color = Colors.black);
    final pico = Path()
      ..moveTo(c.dx + radio * 0.8, c.dy - radio * 0.05)
      ..lineTo(c.dx + radio * 1.5, c.dy + radio * 0.18)
      ..lineTo(c.dx + radio * 0.8, c.dy + radio * 0.4)
      ..close();
    canvas.drawPath(pico, Paint()..color = const Color(0xFFFFB020));
    final ala = Path()
      ..moveTo(c.dx - radio * 0.9, c.dy + radio * 0.15)
      ..quadraticBezierTo(
        c.dx - radio * 0.4,
        c.dy - radio * (_velocidad < 0 ? 1.0 : 0.2),
        c.dx + radio * 0.1,
        c.dy + radio * 0.15,
      );
    canvas.drawPath(
      ala,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }
}

// PAREJA DE COLUMNAS (arriba y abajo) con un hueco entre ellas.
class ParColumnas extends PositionComponent with HasGameReference<NeonFlapGame> {
  static const double ancho = 64;

  final double centroHueco;
  final double hueco;
  bool _puntuada = false;

  ParColumnas({
    required double posicionX,
    required this.centroHueco,
    required this.hueco,
    required double altoJuego,
  }) : super(
          position: Vector2(posicionX, 0),
          size: Vector2(ancho, altoJuego),
          priority: 1,
        );

  @override
  Future<void> onLoad() async {
    final finArriba = centroHueco - hueco / 2;
    final inicioAbajo = centroHueco + hueco / 2;
    add(Columna(position: Vector2.zero(), size: Vector2(ancho, finArriba)));
    add(Columna(
      position: Vector2(0, inicioAbajo),
      size: Vector2(ancho, size.y - inicioAbajo),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.estado != EstadoPartida.jugando) return;

    x -= NeonFlapGame.velocidadColumnas * dt;

    // Punto cuando el personaje deja atrás la columna.
    if (!_puntuada && x + ancho < game.personaje.x) {
      _puntuada = true;
      game.sumarPunto();
    }

    // Eliminamos las columnas que ya salieron de la pantalla.
    if (x < -ancho) removeFromParent();
  }
}

// COLUMNA: rectángulo de neón azul con hitbox rectangular.
class Columna extends PositionComponent {
  Columna({required super.position, required super.size});

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6));
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF0B1A3D));
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = UColores.azulClaro.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = UColores.azulClaro,
    );
  }
}

// FONDO: rejilla de neón que se desplaza y suelo rojo.
class FondoNeon extends Component with HasGameReference<NeonFlapGame> {
  static const double alturaSuelo = 40;
  static const double celda = 44;

  double _desplazamiento = 0;

  FondoNeon() : super(priority: 0);

  @override
  void update(double dt) {
    if (game.estado != EstadoPartida.terminada) {
      _desplazamiento =
          (_desplazamiento + NeonFlapGame.velocidadColumnas * 0.35 * dt) % celda;
    }
  }

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;
    final linea = Paint()
      ..color = UColores.azul.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    for (var x = -_desplazamiento; x < w; x += celda) {
      canvas.drawLine(Offset(x, 0), Offset(x, h - alturaSuelo), linea);
    }
    for (var y = 0.0; y < h - alturaSuelo; y += celda) {
      canvas.drawLine(Offset(0, y), Offset(w, y), linea);
    }

    final suelo = h - alturaSuelo;
    canvas.drawRect(
      Rect.fromLTWH(0, suelo, w, alturaSuelo),
      Paint()..color = const Color(0xFF12060A),
    );
    canvas.drawLine(
      Offset(0, suelo),
      Offset(w, suelo),
      Paint()
        ..color = UColores.rojo.withValues(alpha: 0.6)
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawLine(
      Offset(0, suelo),
      Offset(w, suelo),
      Paint()
        ..color = UColores.rojo
        ..strokeWidth = 2,
    );
  }
}
