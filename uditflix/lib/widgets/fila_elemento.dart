//
// FILA DE ELEMENTO
//
// Fila compacta de las listas "Novedades / Más populares / Juegos gratis"
// y de los resultados de búsqueda: miniatura, título, subtítulo e insignia.
//

import 'package:flutter/material.dart';

import '../models/elemento_catalogo.dart';
import '../theme/uditflix_theme.dart';
import 'arte_neon.dart';
import 'comunes.dart';

// Imagen de un elemento: portada de Internet o ilustración neón.
class MiniaturaElemento extends StatelessWidget {
  final ElementoCatalogo elemento;

  const MiniaturaElemento(this.elemento, {super.key});

  @override
  Widget build(BuildContext context) {
    final juego = elemento.juego;
    if (juego != null) return ArteNeon(juego.arte);
    return ImagenRed(elemento.contenido!.imagenUrl);
  }
}

class FilaElemento extends StatelessWidget {
  final ElementoCatalogo elemento;
  final bool seleccionado;
  final VoidCallback onTap;

  const FilaElemento({
    super.key,
    required this.elemento,
    required this.onTap,
    this.seleccionado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: seleccionado ? UColores.seleccion : UColores.tarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: seleccionado ? UColores.azul : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    width: 72,
                    height: 40,
                    child: MiniaturaElemento(elemento),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        elemento.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: UColores.texto,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        elemento.subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UTextos.pequeno,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Insignia.de(elemento.insignia),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
