//
// PANTALLA DE JUEGOS · UDIT ARCADE
//
// Tienda de juegos con:
// - Juego destacado (Tres en Raya Neón) jugable aquí mismo contra la CPU.
// - Filtros por categoría.
// - Ranking de juegos: JUGAR abre el juego, el resto llega próximamente.
//

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/juego.dart';
import '../theme/uditflix_theme.dart';
import '../utils/abrir.dart';
import '../utils/responsive.dart';
import '../widgets/arte_neon.dart';
import '../widgets/comunes.dart';
import '../widgets/tres_en_raya.dart';

class JuegosScreen extends StatefulWidget {
  const JuegosScreen({super.key});

  @override
  State<JuegosScreen> createState() => JuegosScreenState();
}

class JuegosScreenState extends State<JuegosScreen> {
  final ScrollController _scroll = ScrollController();
  String _categoria = 'Todos';

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Sube hasta el panel "Juega aquí mismo".
  void irATresEnRaya() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formato = Responsive.de(context);
    final margen = Responsive.margen(formato);
    final movil = formato == Formato.movil;

    final visibles = _categoria == 'Todos'
        ? juegos
        : juegos.where((j) => j.categoria == _categoria).toList();

    return SingleChildScrollView(
      controller: _scroll,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(margen, movil ? 20 : 32, margen, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CabeceraPagina(
                  antetitulo: 'UDIT Arcade · Tienda de juegos',
                  titulo: 'Juegos',
                  color: UColores.azulClaro,
                  tamano: movil ? 38 : 48,
                ),
                const SizedBox(height: 20),
                _Destacado(formato: formato),
                const SizedBox(height: 24),
                FilaChips(
                  opciones: const ['Todos', ...categoriasJuego],
                  seleccionada: _categoria,
                  color: UColores.azul,
                  onSeleccion: (c) => setState(() => _categoria = c),
                ),
                const SizedBox(height: 14),
                if (visibles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text('No hay juegos en esta categoría',
                        style: UTextos.cuerpo),
                  ),
                for (final juego in visibles)
                  _FilaRanking(
                    posicion: juegos.indexOf(juego) + 1,
                    juego: juego,
                    movil: movil,
                    onJugar: () =>
                        abrirJuego(context, juego, irATresEnRaya: irATresEnRaya),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bloque destacado: portada + tablero "Juega aquí mismo".
class _Destacado extends StatelessWidget {
  final Formato formato;

  const _Destacado({required this.formato});

  @override
  Widget build(BuildContext context) {
    final juego = juegos.first;

    final portada = Stack(
      fit: StackFit.expand,
      children: [
        ArteNeon(juego.arte),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.45, 1],
              colors: [Colors.transparent, Color(0xEE000000)],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Insignia.de('DESTACADO', relleno: true),
              const SizedBox(height: 8),
              Text(
                juego.titulo.toUpperCase(),
                maxLines: 2,
                style: UTextos.titular(formato == Formato.escritorio ? 34 : 26),
              ),
              const SizedBox(height: 8),
              FilaEtiquetas(juego.etiquetas),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  _Dato(Icons.thumb_up_alt_outlined, juego.opiniones),
                  _Dato(Icons.people_outline, '${juego.jugando} jugando'),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final decoracion = BoxDecoration(
      color: UColores.panel,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: UColores.borde),
    );

    // Móvil: portada arriba y tablero debajo.
    if (formato == Formato.movil) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: decoracion,
        child: Column(
          children: [
            SizedBox(height: 240, child: portada),
            const TresEnRaya(),
          ],
        ),
      );
    }

    // Tablet y escritorio: imagen y tablero al 50 / 50.
    return Container(
      height: formato == Formato.escritorio ? 430 : 380,
      clipBehavior: Clip.antiAlias,
      decoration: decoracion,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: portada),
          const Expanded(child: Center(child: TresEnRaya())),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Dato(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: UColores.azulClaro),
        const SizedBox(width: 5),
        Text(texto, style: const TextStyle(fontSize: 11, color: UColores.texto)),
      ],
    );
  }
}

// Fila del ranking de juegos.
class _FilaRanking extends StatelessWidget {
  final int posicion;
  final Juego juego;
  final bool movil;
  final VoidCallback onJugar;

  const _FilaRanking({
    required this.posicion,
    required this.juego,
    required this.movil,
    required this.onJugar,
  });

  @override
  Widget build(BuildContext context) {
    final boton = juego.jugable
        ? BotonUdit('Jugar', compacto: true, onPressed: onJugar)
        : BotonUdit('Próximamente',
            compacto: true, principal: false, onPressed: onJugar);

    final opiniones = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: juego.opiniones,
            style: const TextStyle(color: UColores.azulClaro),
          ),
          TextSpan(text: ' · ${juego.jugando} jugando'),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 10.5, color: UColores.textoSuave),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: UColores.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: UColores.borde),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$posicion',
              textAlign: TextAlign.center,
              style: UTextos.titular(18, color: UColores.textoSuave),
            ),
          ),
          const SizedBox(width: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              width: movil ? 52 : 58,
              height: movil ? 68 : 76,
              child: ArteNeon(juego.arte),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  juego.titulo.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UTextos.titular(movil ? 17 : 21),
                ),
                const SizedBox(height: 5),
                FilaEtiquetas(juego.etiquetas),
                const SizedBox(height: 4),
                opiniones,
                if (movil) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Insignia.de('GRATIS'),
                      const SizedBox(width: 8),
                      Flexible(child: boton),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!movil) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Insignia.de('GRATIS'),
                const SizedBox(height: 8),
                boton,
              ],
            ),
          ],
        ],
      ),
    );
  }
}
