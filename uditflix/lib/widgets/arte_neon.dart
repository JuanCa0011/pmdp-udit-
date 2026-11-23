//
// ILUSTRACIONES NEÓN DE LOS JUEGOS
//
// Las portadas de los juegos se dibujan con CustomPainter,
// así no dependen de Internet y mantienen el estilo rojo/azul neón.
//

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/juego.dart';
import '../theme/uditflix_theme.dart';

class ArteNeon extends StatelessWidget {
  final ArteJuego arte;

  const ArteNeon(this.arte, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.1,
            colors: [Color(0xFF0A1330), Color(0xFF02040A)],
          ),
        ),
        child: CustomPaint(
          painter: _PintorNeon(arte),
          size: Size.infinite,
        ),
      ),
    );
  }
}

// Utilidades para dibujar trazos con brillo.
class Neon {
  Neon._();

  static void trazo(Canvas canvas, Path path, Color color, double ancho) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ancho * 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, ancho * 1.6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ancho
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ancho * 0.3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.75),
    );
  }

  static void relleno(Canvas canvas, Rect rect, Color color, {double radio = 2}) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radio));
    canvas.drawRRect(
      rrect.inflate(rect.shortestSide * 0.12),
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rect.shortestSide * 0.3),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
    canvas.drawRRect(
      rrect.deflate(rect.shortestSide * 0.18),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, rect.shortestSide * 0.06)
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  static void cruz(Canvas canvas, Offset c, double r, double ancho) {
    final p = Path()
      ..moveTo(c.dx - r, c.dy - r)
      ..lineTo(c.dx + r, c.dy + r)
      ..moveTo(c.dx + r, c.dy - r)
      ..lineTo(c.dx - r, c.dy + r);
    trazo(canvas, p, UColores.rojo, ancho);
  }

  static void circulo(Canvas canvas, Offset c, double r, double ancho) {
    trazo(canvas, Path()..addOval(Rect.fromCircle(center: c, radius: r)),
        UColores.azulClaro, ancho);
  }
}

class _PintorNeon extends CustomPainter {
  final ArteJuego arte;

  _PintorNeon(this.arte);

  static const rojo = UColores.rojo;
  static const azul = UColores.azulClaro;

  @override
  void paint(Canvas canvas, Size s) {
    if (s.isEmpty) return;
    switch (arte) {
      case ArteJuego.tresEnRaya:
        _tresEnRaya(canvas, s);
      case ArteJuego.neonFlap:
        _neonFlap(canvas, s);
      case ArteJuego.pixelRunner:
        _pixelRunner(canvas, s);
      case ArteJuego.neonBlocks:
        _neonBlocks(canvas, s);
      case ArteJuego.galaxyDefender:
        _galaxy(canvas, s);
      case ArteJuego.neonSnake:
        _snake(canvas, s);
      case ArteJuego.memoriaFlash:
        _memoria(canvas, s);
    }
  }

  // Rejilla 3x3 con X rojas y O azules, ligeramente ampliada.
  void _tresEnRaya(Canvas canvas, Size s) {
    final lado = math.max(s.width, s.height) * 1.08;
    final origen = Offset((s.width - lado) / 2, (s.height - lado) / 2);
    final celda = lado / 3;
    final ancho = math.max(1.5, lado * 0.012);

    final rejilla = Path();
    for (var i = 1; i < 3; i++) {
      rejilla
        ..moveTo(origen.dx + celda * i, origen.dy)
        ..lineTo(origen.dx + celda * i, origen.dy + lado)
        ..moveTo(origen.dx, origen.dy + celda * i)
        ..lineTo(origen.dx + lado, origen.dy + celda * i);
    }
    Neon.trazo(canvas, rejilla, azul, ancho);

    Offset centro(int f, int c) =>
        origen + Offset(celda * c + celda / 2, celda * f + celda / 2);
    final r = celda * 0.3;

    Neon.cruz(canvas, centro(0, 0), r, ancho * 2.2);
    Neon.cruz(canvas, centro(1, 1), r, ancho * 2.2);
    Neon.cruz(canvas, centro(2, 2), r, ancho * 2.2);
    Neon.circulo(canvas, centro(0, 2), r * 1.1, ancho * 2);
    Neon.circulo(canvas, centro(1, 0), r * 1.1, ancho * 2);
    Neon.circulo(canvas, centro(2, 1), r * 1.1, ancho * 2);
  }

  // Columnas azules con hueco y un pájaro rojo volando.
  void _neonFlap(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final ancho = math.max(1.4, w * 0.01);
    final colW = w * 0.14;

    void columna(double x, double hueco) {
      final g = h * 0.34;
      Neon.trazo(canvas,
          Path()..addRRect(RRect.fromLTRBR(x, -10, x + colW, hueco - g / 2, const Radius.circular(4))),
          azul, ancho);
      Neon.trazo(canvas,
          Path()..addRRect(RRect.fromLTRBR(x, hueco + g / 2, x + colW, h + 10, const Radius.circular(4))),
          azul, ancho);
    }

    columna(w * 0.55, h * 0.45);
    columna(w * 0.88, h * 0.62);

    // Suelo con perspectiva.
    final suelo = Path();
    for (var i = 0; i < 6; i++) {
      final y = h * 0.86 + i * i * h * 0.006;
      suelo
        ..moveTo(0, y)
        ..lineTo(w, y);
    }
    Neon.trazo(canvas, suelo, rojo.withValues(alpha: 0.5), ancho * 0.5);

    // Pájaro.
    final c = Offset(w * 0.28, h * 0.42);
    final r = math.min(w, h) * 0.11;
    canvas.drawCircle(
        c, r * 1.6, Paint()..color = rojo.withValues(alpha: 0.35)..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
    canvas.drawCircle(c, r, Paint()..color = rojo);
    canvas.drawCircle(c + Offset(r * 0.35, -r * 0.25), r * 0.28, Paint()..color = Colors.white);
    canvas.drawCircle(c + Offset(r * 0.45, -r * 0.25), r * 0.12, Paint()..color = Colors.black);
    final pico = Path()
      ..moveTo(c.dx + r * 0.8, c.dy - r * 0.05)
      ..lineTo(c.dx + r * 1.5, c.dy + r * 0.15)
      ..lineTo(c.dx + r * 0.8, c.dy + r * 0.35)
      ..close();
    canvas.drawPath(pico, Paint()..color = const Color(0xFFFFB020));
    Neon.trazo(
        canvas,
        Path()
          ..moveTo(c.dx - r * 0.9, c.dy + r * 0.1)
          ..quadraticBezierTo(c.dx - r * 0.4, c.dy - r * 0.9, c.dx + r * 0.1, c.dy + r * 0.1),
        Colors.white,
        ancho * 0.8);
  }

  // Personaje pixelado sobre plataformas y pinchos.
  void _pixelRunner(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final p = math.min(w, h) * 0.045;

    void plataforma(double x, double y, double largo) =>
        Neon.relleno(canvas, Rect.fromLTWH(x, y, largo, p * 0.9), azul);

    plataforma(w * 0.05, h * 0.72, w * 0.4);
    plataforma(w * 0.55, h * 0.55, w * 0.35);
    plataforma(w * 0.1, h * 0.35, w * 0.25);

    // Pinchos.
    final pinchos = Path();
    for (var i = 0; i < 8; i++) {
      final x = w * 0.5 + i * p * 1.4;
      pinchos
        ..moveTo(x, h * 0.95)
        ..lineTo(x + p * 0.7, h * 0.88)
        ..lineTo(x + p * 1.4, h * 0.95);
    }
    Neon.trazo(canvas, pinchos, rojo, p * 0.25);

    // Personaje.
    const sprite = [
      '..XX..',
      '..XX..',
      '.XXXX.',
      'X.XX.X',
      '..XX..',
      '.X..X.',
      'X....X',
    ];
    final origen = Offset(w * 0.62, h * 0.55 - sprite.length * p);
    for (var f = 0; f < sprite.length; f++) {
      for (var c = 0; c < sprite[f].length; c++) {
        if (sprite[f][c] == 'X') {
          Neon.relleno(canvas,
              Rect.fromLTWH(origen.dx + c * p, origen.dy + f * p, p * 0.92, p * 0.92),
              f < 2 ? rojo : azul,
              radio: 0.5);
        }
      }
    }
    canvas.drawCircle(Offset(w * 0.82, h * 0.18), p * 1.3, Paint()..color = rojo.withValues(alpha: 0.9));
  }

  // Bloques apilados y una pieza cayendo.
  void _neonBlocks(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final b = math.min(w / 8, h / 8);
    final cols = (w / b).floor();
    final x0 = (w - cols * b) / 2;
    final rnd = math.Random(7);

    for (var c = 0; c < cols; c++) {
      final alto = 1 + rnd.nextInt(4);
      for (var f = 0; f < alto; f++) {
        Neon.relleno(
          canvas,
          Rect.fromLTWH(x0 + c * b + 1.5, h - (f + 1) * b + 1.5, b - 3, b - 3),
          (c + f).isEven ? azul : rojo,
        );
      }
    }

    final pieza = [const Offset(0, 0), const Offset(1, 0), const Offset(2, 0), const Offset(1, 1)];
    for (final o in pieza) {
      Neon.relleno(
        canvas,
        Rect.fromLTWH(x0 + (cols / 2 - 1.5 + o.dx) * b + 1.5, h * 0.12 + o.dy * b + 1.5, b - 3, b - 3),
        rojo,
      );
    }
  }

  // Estrellas, invasores rojos y nave azul.
  void _galaxy(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final rnd = math.Random(3);
    for (var i = 0; i < 60; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * w, rnd.nextDouble() * h),
        rnd.nextDouble() * 1.2 + 0.3,
        Paint()..color = Colors.white.withValues(alpha: rnd.nextDouble() * 0.7 + 0.2),
      );
    }

    final p = math.min(w, h) * 0.022;
    const invasor = ['.X...X.', '..XXX..', '.XXXXX.', 'XX.X.XX', 'X.....X'];
    for (var n = 0; n < 4; n++) {
      final o = Offset(w * (0.12 + n * 0.21), h * (0.16 + (n.isEven ? 0 : 0.08)));
      for (var f = 0; f < invasor.length; f++) {
        for (var c = 0; c < invasor[f].length; c++) {
          if (invasor[f][c] == 'X') {
            Neon.relleno(canvas, Rect.fromLTWH(o.dx + c * p, o.dy + f * p, p * 0.9, p * 0.9), rojo,
                radio: 0.4);
          }
        }
      }
    }

    final nave = Offset(w * 0.5, h * 0.8);
    final r = math.min(w, h) * 0.09;
    final pathNave = Path()
      ..moveTo(nave.dx, nave.dy - r)
      ..lineTo(nave.dx + r * 0.8, nave.dy + r * 0.6)
      ..lineTo(nave.dx, nave.dy + r * 0.25)
      ..lineTo(nave.dx - r * 0.8, nave.dy + r * 0.6)
      ..close();
    Neon.trazo(canvas, pathNave, azul, math.max(1.2, r * 0.08));
    final disparos = Path();
    for (var i = 1; i <= 3; i++) {
      disparos
        ..moveTo(nave.dx, nave.dy - r - i * r * 0.9)
        ..lineTo(nave.dx, nave.dy - r - i * r * 0.9 + r * 0.4);
    }
    Neon.trazo(canvas, disparos, azul, math.max(1.2, r * 0.07));
  }

  // Serpiente azul sobre rejilla en perspectiva y manzana roja.
  void _snake(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final ancho = math.max(1.0, w * 0.006);

    final rejilla = Path();
    for (var i = 0; i <= 10; i++) {
      final x = w * i / 10;
      rejilla
        ..moveTo(w / 2 + (x - w / 2) * 0.3, h * 0.55)
        ..lineTo(x, h);
    }
    for (var i = 0; i < 6; i++) {
      final y = h * 0.55 + (h * 0.45) * (i * i) / 25;
      rejilla
        ..moveTo(0, y)
        ..lineTo(w, y);
    }
    Neon.trazo(canvas, rejilla, azul.withValues(alpha: 0.45), ancho);

    final cuerpo = Path()..moveTo(w * 0.15, h * 0.2);
    cuerpo
      ..cubicTo(w * 0.7, h * 0.05, w * 0.85, h * 0.35, w * 0.45, h * 0.45)
      ..cubicTo(w * 0.1, h * 0.55, w * 0.3, h * 0.85, w * 0.55, h * 0.75);
    Neon.trazo(canvas, cuerpo, azul, math.min(w, h) * 0.07);

    final m = Offset(w * 0.78, h * 0.78);
    final r = math.min(w, h) * 0.07;
    canvas.drawCircle(m, r * 1.8,
        Paint()..color = rojo.withValues(alpha: 0.4)..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
    canvas.drawCircle(m, r, Paint()..color = rojo);
  }

  // Cartas inclinadas con símbolos.
  void _memoria(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final lado = math.min(w, h) * 0.38;
    final cartas = [
      (Offset(w * 0.3, h * 0.32), -0.3, rojo),
      (Offset(w * 0.7, h * 0.3), 0.25, azul),
      (Offset(w * 0.35, h * 0.75), 0.2, azul),
      (Offset(w * 0.72, h * 0.72), -0.15, rojo),
    ];
    for (final (centro, angulo, color) in cartas) {
      canvas.save();
      canvas.translate(centro.dx, centro.dy);
      canvas.rotate(angulo);
      final rect = Rect.fromCenter(center: Offset.zero, width: lado * 0.8, height: lado);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(lado * 0.08)),
          Paint()..color = color.withValues(alpha: 0.18));
      Neon.trazo(canvas, Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(lado * 0.08))),
          color, math.max(1.2, lado * 0.03));
      Neon.trazo(canvas, _estrella(lado * 0.22), color, math.max(1.0, lado * 0.025));
      canvas.restore();
    }
  }

  Path _estrella(double r) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final radio = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final punto = Offset(math.cos(a) * radio, math.sin(a) * radio);
      if (i == 0) {
        p.moveTo(punto.dx, punto.dy);
      } else {
        p.lineTo(punto.dx, punto.dy);
      }
    }
    return p..close();
  }

  @override
  bool shouldRepaint(_PintorNeon old) => old.arte != arte;
}
