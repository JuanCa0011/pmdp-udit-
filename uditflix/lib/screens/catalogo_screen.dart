
//
// PANTALLA DEL CATÁLOGO · VIDEOS
//
// Muestra todas las películas y series en una rejilla
// de 4 / 3 / 2 columnas (escritorio / tablet / móvil),
// con filtros por categoría.
//
// Al pulsar una tarjeta navegamos a la ficha del contenido.
//

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/contenido.dart';
import '../theme/uditflix_theme.dart';
import '../utils/abrir.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';

class CatalogoScreen extends StatelessWidget {

  // Categoría seleccionada ('Todo', 'Acción'...).
  final String categoria;
  final ValueChanged<String> onCategoria;
  final VoidCallback onIrAJuegos;

  const CatalogoScreen({
    super.key,
    required this.categoria,
    required this.onCategoria,
    required this.onIrAJuegos,
  });

  static const List<String> filtros = ['Todo', ...categoriasVideo, 'Juegos'];

  @override
  Widget build(BuildContext context) {
    final formato = Responsive.de(context);
    final margen = Responsive.margen(formato);
    final movil = formato == Formato.movil;

    final List<Contenido> visibles = categoria == 'Todo'
        ? contenidos
        : contenidos.where((c) => c.categoria == categoria).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(margen, movil ? 20 : 32, margen, 18),
            child: CabeceraPagina(
              antetitulo: 'Catálogo',
              titulo: 'Videos',
              color: UColores.rojo,
              tamano: movil ? 38 : 48,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: margen, vertical: 14),
            child: FilaChips(
              opciones: filtros,
              seleccionada: categoria,
              onSeleccion: onCategoria,
              envolver: !movil,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(margen),
            child: categoria == 'Juegos'
                ? _AvisoJuegos(onIrAJuegos: onIrAJuegos)
                : _Rejilla(contenidos: visibles, formato: formato),
          ),
        ],
      ),
    );
  }
}

class _Rejilla extends StatelessWidget {
  final List<Contenido> contenidos;
  final Formato formato;

  const _Rejilla({required this.contenidos, required this.formato});

  @override
  Widget build(BuildContext context) {
    if (contenidos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No hay vídeos en esta categoría', style: UTextos.cuerpo),
        ),
      );
    }

    final columnas = Responsive.columnas(formato);
    const espacio = 14.0;

    return LayoutBuilder(
      builder: (context, c) {
        // Alto de cada tarjeta: imagen 16:9 + línea de datos.
        final anchoTarjeta = (c.maxWidth - espacio * (columnas - 1)) / columnas;
        final altoTarjeta = anchoTarjeta * 9 / 16 + 30;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contenidos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: espacio,
            mainAxisSpacing: 18,
            mainAxisExtent: altoTarjeta,
          ),
          itemBuilder: (context, i) => TarjetaVideo(contenido: contenidos[i]),
        );
      },
    );
  }
}

// Tarjeta del catálogo: portada, título, progreso y datos.
class TarjetaVideo extends StatelessWidget {
  final Contenido contenido;

  const TarjetaVideo({super.key, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => abrirContenido(context, contenido),
      borderRadius: BorderRadius.circular(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImagenRed(contenido.imagenUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.45, 1],
                        colors: [Colors.transparent, Color(0xDD000000)],
                      ),
                    ),
                  ),
                  if (contenido.estreno)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Insignia.de('NUEVO', relleno: true),
                    ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 9,
                    child: Text(
                      contenido.titulo.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UTextos.titular(16),
                    ),
                  ),
                  // Barra de progreso de visionado.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(
                      value: contenido.progreso,
                      minHeight: 3,
                      color: UColores.rojo,
                      backgroundColor: const Color(0x33FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                '${contenido.valoracion}% para ti',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: UColores.azulClaro,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: UColores.textoTenue),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(contenido.edad,
                    style: const TextStyle(fontSize: 9.5, color: UColores.textoSuave)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${contenido.anio} · ${contenido.duracion}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: UColores.textoSuave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvisoJuegos extends StatelessWidget {
  final VoidCallback onIrAJuegos;

  const _AvisoJuegos({required this.onIrAJuegos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: UColores.tarjeta,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: UColores.borde),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_esports_outlined, size: 40, color: UColores.azulClaro),
          const SizedBox(height: 12),
          Text('LOS JUEGOS ESTÁN EN UDIT ARCADE',
              textAlign: TextAlign.center, style: UTextos.titular(22)),
          const SizedBox(height: 6),
          const Text(
            'Juega gratis a Tres en Raya Neón y Neon Flap desde la tienda.',
            textAlign: TextAlign.center,
            style: UTextos.cuerpo,
          ),
          const SizedBox(height: 16),
          BotonUdit('Ir a juegos', icono: Icons.arrow_forward, onPressed: onIrAJuegos),
        ],
      ),
    );
  }
}
