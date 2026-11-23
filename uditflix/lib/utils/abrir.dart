//
// ACCIONES DE NAVEGACIÓN
//
// Funciones que abren una película o un juego desde cualquier pantalla,
// para no repetir el mismo Navigator.push en cada sitio.
//

import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../models/elemento_catalogo.dart';
import '../models/juego.dart';
import '../screens/ficha_screen.dart';
import '../screens/neon_flap_screen.dart';
import '../widgets/comunes.dart';

// Abre la ficha de detalle de una película o serie.
void abrirContenido(BuildContext context, Contenido contenido) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => FichaScreen(contenido: contenido)),
  );
}

// Abre un juego según su destino.
// [irATresEnRaya] lleva al panel "Juega aquí mismo" de la tienda.
void abrirJuego(
  BuildContext context,
  Juego juego, {
  required VoidCallback irATresEnRaya,
}) {
  switch (juego.destino) {
    case DestinoJuego.neonFlap:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NeonFlapScreen()),
      );
    case DestinoJuego.tresEnRaya:
      irATresEnRaya();
    case DestinoJuego.proximamente:
      avisarProximamente(context, juego.titulo);
  }
}

void abrirElemento(
  BuildContext context,
  ElementoCatalogo elemento, {
  required VoidCallback irATresEnRaya,
}) {
  final juego = elemento.juego;
  if (juego != null) {
    abrirJuego(context, juego, irATresEnRaya: irATresEnRaya);
  } else {
    abrirContenido(context, elemento.contenido!);
  }
}
