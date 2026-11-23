//
// PANTALLA DE PERFIL
//
// Acceso "Perfil" de la barra inferior: datos básicos del usuario
// y lo que tiene a medio ver.
//

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/elemento_catalogo.dart';
import '../theme/uditflix_theme.dart';
import '../utils/abrir.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';
import '../widgets/fila_elemento.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final margen = Responsive.margen(Responsive.de(context));
    final empezados = contenidos.where((c) => c.progreso > 0).toList();

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: EdgeInsets.fromLTRB(margen, 28, margen, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AvatarUsuario(tamano: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PERFIL', style: UTextos.antetitulo(UColores.rojo)),
                          const SizedBox(height: 4),
                          Text('USUARIO UDIT', style: UTextos.titular(28)),
                          const SizedBox(height: 4),
                          const Text('Plan UDITflix · Videos y juegos',
                              style: UTextos.pequeno),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const TituloSeccion('Seguir viendo'),
                for (final c in empezados)
                  FilaElemento(
                    elemento: ElementoCatalogo.video(c),
                    onTap: () => abrirContenido(context, c),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
