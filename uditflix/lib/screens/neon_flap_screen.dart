//
// PANTALLA DE NEON FLAP (UDIT ARCADE)
//
// Contiene el GameWidget de Flame y los overlays de Flutter:
// marcador, mensaje de inicio y pantalla de Game Over.
//

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../arcade/neon_flap_game.dart';
import '../theme/uditflix_theme.dart';
import '../widgets/comunes.dart';

class NeonFlapScreen extends StatefulWidget {
  const NeonFlapScreen({super.key});

  @override
  State<NeonFlapScreen> createState() => _NeonFlapScreenState();
}

class _NeonFlapScreenState extends State<NeonFlapScreen> {
  // El juego se crea una sola vez para que no se reinicie al reconstruir.
  late final NeonFlapGame _juego = NeonFlapGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UDIT ARCADE', style: UTextos.antetitulo(UColores.azulClaro)),
            const SizedBox(height: 2),
            Text('NEON FLAP', style: UTextos.titular(22)),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            // En pantallas anchas el juego mantiene proporción de móvil.
            constraints: const BoxConstraints(maxWidth: 480),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GameWidget<NeonFlapGame>(
                game: _juego,
                initialActiveOverlays: const [
                  NeonFlapGame.overlayMarcador,
                  NeonFlapGame.overlayInicio,
                ],
                overlayBuilderMap: {
                  NeonFlapGame.overlayMarcador: (context, juego) =>
                      _Marcador(juego),
                  NeonFlapGame.overlayInicio: (context, juego) =>
                      const _MensajeInicio(),
                  NeonFlapGame.overlayGameOver: (context, juego) =>
                      _GameOver(juego),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Marcador extends StatelessWidget {
  final NeonFlapGame juego;

  const _Marcador(this.juego);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.85),
        child: ValueListenableBuilder<int>(
          valueListenable: juego.puntuacion,
          builder: (context, puntos, _) => Text(
            '$puntos',
            style: UTextos.titular(54).copyWith(
              shadows: const [Shadow(color: UColores.azul, blurRadius: 18)],
            ),
          ),
        ),
      ),
    );
  }
}

class _MensajeInicio extends StatelessWidget {
  const _MensajeInicio();

  @override
  Widget build(BuildContext context) {
    // IgnorePointer deja pasar la pulsación al juego.
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, 0.45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_outlined, color: UColores.texto, size: 34),
            const SizedBox(height: 8),
            Text('PULSA PARA VOLAR', style: UTextos.titular(20)),
            const SizedBox(height: 4),
            const Text(
              'Esquiva las columnas de neón',
              style: TextStyle(color: UColores.textoSuave, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOver extends StatelessWidget {
  final NeonFlapGame juego;

  const _GameOver(this.juego);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: UColores.tarjeta,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: UColores.borde),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GAME OVER', style: UTextos.titular(36, color: UColores.rojo)),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Dato('PUNTOS', '${juego.puntuacion.value}', UColores.texto),
                _Dato('MEJOR', '${NeonFlapGame.mejorPuntuacion}',
                    UColores.azulClaro),
              ],
            ),
            const SizedBox(height: 22),
            BotonUdit(
              'Reiniciar',
              icono: Icons.refresh,
              onPressed: juego.reiniciar,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Volver a UDIT Arcade',
                style: TextStyle(color: UColores.textoSuave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;

  const _Dato(this.etiqueta, this.valor, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(etiqueta, style: UTextos.antetitulo(UColores.textoSuave)),
        const SizedBox(height: 4),
        Text(valor, style: UTextos.titular(30, color: color)),
      ],
    );
  }
}
