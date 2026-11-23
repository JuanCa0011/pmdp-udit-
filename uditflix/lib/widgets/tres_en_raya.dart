//
// TRES EN RAYA NEÓN · "JUEGA AQUÍ MISMO"
//
// Panel jugable de la tienda: el usuario juega con X contra la CPU (O).
// La lógica está separada en funciones puras para poder probarla.
//

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/uditflix_theme.dart';
import 'arte_neon.dart';

const String jugadorX = 'X';
const String jugadorO = 'O';

const List<List<int>> _lineas = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // filas
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columnas
  [0, 4, 8], [2, 4, 6], // diagonales
];

// Devuelve 'X' u 'O' si alguien ha ganado, o null.
String? ganadorTresEnRaya(List<String?> tablero) {
  for (final l in _lineas) {
    final a = tablero[l[0]];
    if (a != null && a == tablero[l[1]] && a == tablero[l[2]]) return a;
  }
  return null;
}

// Elige la casilla de la CPU: ganar, bloquear, centro, esquina o lado.
int jugadaCpu(List<String?> tablero, {math.Random? azar}) {
  final libres = [for (var i = 0; i < 9; i++) if (tablero[i] == null) i];

  int? completar(String jugador) {
    for (final i in libres) {
      final prueba = [...tablero]..[i] = jugador;
      if (ganadorTresEnRaya(prueba) == jugador) return i;
    }
    return null;
  }

  final ganar = completar(jugadorO);
  if (ganar != null) return ganar;

  final bloquear = completar(jugadorX);
  if (bloquear != null) return bloquear;

  if (tablero[4] == null) return 4;

  final r = azar ?? math.Random();
  final esquinas = [0, 2, 6, 8].where(libres.contains).toList();
  if (esquinas.isNotEmpty) return esquinas[r.nextInt(esquinas.length)];

  return libres[r.nextInt(libres.length)];
}

class TresEnRaya extends StatefulWidget {
  const TresEnRaya({super.key});

  @override
  State<TresEnRaya> createState() => _TresEnRayaState();
}

class _TresEnRayaState extends State<TresEnRaya> {
  List<String?> _tablero = List.filled(9, null);
  int _victorias = 0;
  int _empates = 0;
  int _derrotas = 0;
  bool _turnoCpu = false;
  String? _ganador;
  List<int> _lineaGanadora = const [];
  Timer? _temporizadorCpu;

  bool get _terminado => _ganador != null || !_tablero.contains(null);

  String get _estado {
    if (_ganador == jugadorX) return '¡HAS GANADO!';
    if (_ganador == jugadorO) return 'GANA LA CPU';
    if (_terminado) return 'EMPATE';
    if (_turnoCpu) return 'PIENSA LA CPU...';
    return 'TU TURNO (X)';
  }

  @override
  void dispose() {
    _temporizadorCpu?.cancel();
    super.dispose();
  }

  void _pulsar(int casilla) {
    if (_turnoCpu || _terminado || _tablero[casilla] != null) return;

    setState(() => _colocar(casilla, jugadorX));
    if (_terminado) return;

    setState(() => _turnoCpu = true);
    _temporizadorCpu = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _colocar(jugadaCpu(_tablero), jugadorO);
        _turnoCpu = false;
      });
    });
  }

  void _colocar(int casilla, String jugador) {
    _tablero = [..._tablero]..[casilla] = jugador;
    _ganador = ganadorTresEnRaya(_tablero);

    if (_ganador != null) {
      _lineaGanadora = _lineas.firstWhere(
        (l) => l.every((i) => _tablero[i] == _ganador),
      );
      if (_ganador == jugadorX) {
        _victorias++;
      } else {
        _derrotas++;
      }
    } else if (!_tablero.contains(null)) {
      _empates++;
    }
  }

  void _nuevaPartida() {
    _temporizadorCpu?.cancel();
    setState(() {
      _tablero = List.filled(9, null);
      _ganador = null;
      _lineaGanadora = const [];
      _turnoCpu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // El tablero se adapta al espacio disponible.
        final porAlto = c.hasBoundedHeight ? c.maxHeight - 185 : 280.0;
        final lado = math.min(c.maxWidth * 0.8, porAlto).clamp(120.0, 300.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_esports_outlined,
                      size: 13, color: UColores.rojo),
                  const SizedBox(width: 6),
                  Text('JUEGA AQUÍ MISMO',
                      style: UTextos.antetitulo(UColores.rojo)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Marcador('TÚ $_victorias', UColores.rojo),
                  _Marcador('EMPATES $_empates', UColores.texto),
                  _Marcador('CPU $_derrotas', UColores.azulClaro),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: lado,
                height: lado,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF070A11),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: UColores.borde, width: 1.5),
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < 9; i++)
                      _Casilla(
                        valor: _tablero[i],
                        resaltada: _lineaGanadora.contains(i),
                        onTap: () => _pulsar(i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(_estado, style: UTextos.titular(17)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _nuevaPartida,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'NUEVA PARTIDA',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: UColores.texto,
                  side: const BorderSide(color: UColores.borde),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Marcador extends StatelessWidget {
  final String texto;
  final Color color;

  const _Marcador(this.texto, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: UTextos.titular(14, color: color));
  }
}

class _Casilla extends StatelessWidget {
  final String? valor;
  final bool resaltada;
  final VoidCallback onTap;

  const _Casilla({
    required this.valor,
    required this.resaltada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: resaltada ? const Color(0xFF1B2540) : UColores.tarjetaClara,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: valor == null
            ? const SizedBox.expand()
            : CustomPaint(
                painter: _PintorFicha(valor!),
                size: Size.infinite,
              ),
      ),
    );
  }
}

class _PintorFicha extends CustomPainter {
  final String valor;

  _PintorFicha(this.valor);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.26;
    final ancho = size.shortestSide * 0.06;
    if (valor == jugadorX) {
      Neon.cruz(canvas, c, r, ancho);
    } else {
      Neon.circulo(canvas, c, r * 1.1, ancho);
    }
  }

  @override
  bool shouldRepaint(_PintorFicha old) => old.valor != valor;
}
