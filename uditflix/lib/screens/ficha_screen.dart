
//
// PANTALLA DE FICHA
//
// Esta pantalla recibe un objeto Contenido desde el catálogo.
//
// Muestra la portada, la información de la película o serie
// y el botón que abre el reproductor de vídeo.
//

import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../theme/uditflix_theme.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';
import 'reproductor_screen.dart';

class FichaScreen extends StatelessWidget {

  // Contenido que recibimos desde la pantalla anterior.
  final Contenido contenido;

  // Constructor de la pantalla.
  // required obliga a proporcionar un contenido.
  const FichaScreen({
    super.key,
    required this.contenido,
  });

  void _reproducir(BuildContext context) {
    // Abrimos la pantalla de reproducción.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorScreen(contenido: contenido),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formato = Responsive.de(context);
    final movil = formato == Formato.movil;
    final altoPortada = movil ? 300.0 : 440.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Portada con degradado hacia el negro.
            SizedBox(
              height: altoPortada,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImagenRed(contenido.imagenUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.35, 1.0],
                        colors: [Color(0x99000000), Color(0x22000000), UColores.fondo],
                      ),
                    ),
                  ),
                  Positioned(
                    left: Responsive.margen(formato),
                    right: Responsive.margen(formato),
                    bottom: 16,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Insignia.de(
                              contenido.estreno ? 'ESTRENO' : contenido.tipo.toUpperCase(),
                              relleno: true,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                contenido.titulo.toUpperCase(),
                                style: UTextos.titular(movil ? 34 : 56),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Información del contenido.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.margen(formato),
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Valoración.
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined,
                              size: 15, color: UColores.azulClaro),
                          const SizedBox(width: 6),
                          const Text('Valoración: ', style: UTextos.pequeno),
                          Text(
                            '${contenido.valoracion}% para ti',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: UColores.azulClaro,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tipo, categoría, edad, año y duración.
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Etiqueta(contenido.tipo),
                          Etiqueta(contenido.categoria),
                          Etiqueta(contenido.edad),
                          Etiqueta('${contenido.anio}'),
                          Etiqueta(contenido.duracion),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Descripción completa.
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Text(
                          contenido.descripcion,
                          style: UTextos.cuerpo.copyWith(fontSize: 15),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Botón para abrir el reproductor.
                      SizedBox(
                        width: movil ? double.infinity : null,
                        child: BotonUdit(
                          'Reproducir',
                          icono: Icons.play_arrow_rounded,
                          onPressed: () => _reproducir(context),
                        ),
                      ),

                      if (contenido.progreso > 0) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 160,
                              child: LinearProgressIndicator(
                                value: contenido.progreso,
                                minHeight: 3,
                                color: UColores.rojo,
                                backgroundColor: UColores.tarjetaClara,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Visto al ${(contenido.progreso * 100).round()}%',
                              style: UTextos.pequeno,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
