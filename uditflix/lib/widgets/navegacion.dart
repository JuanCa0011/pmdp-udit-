//
// NAVEGACIÓN PRINCIPAL
//
// Escritorio y tablet: cabecera superior con Inicio / Videos / Juegos,
// buscador, notificaciones y avatar.
// Móvil: cabecera compacta y barra inferior con 5 accesos.
//

import 'package:flutter/material.dart';

import '../theme/uditflix_theme.dart';
import '../utils/responsive.dart';
import 'comunes.dart';

// Índices de las secciones de la aplicación.
class Seccion {
  Seccion._();

  static const int inicio = 0;
  static const int videos = 1;
  static const int juegos = 2;
  static const int buscar = 3;
  static const int perfil = 4;
}

class CabeceraAncha extends StatelessWidget {
  final int indice;
  final ValueChanged<int> onNavegar;
  final Formato formato;

  const CabeceraAncha({
    super.key,
    required this.indice,
    required this.onNavegar,
    required this.formato,
  });

  @override
  Widget build(BuildContext context) {
    final escritorio = formato == Formato.escritorio;

    return Container(
      height: 58,
      padding: EdgeInsets.symmetric(horizontal: escritorio ? 24 : 16),
      decoration: const BoxDecoration(
        color: UColores.fondo,
        border: Border(bottom: BorderSide(color: UColores.borde)),
      ),
      child: Row(
        children: [
          LogoUditflix(tamano: escritorio ? 24 : 20),
          SizedBox(width: escritorio ? 28 : 14),
          _BotonNav('Inicio', Seccion.inicio, indice, onNavegar),
          _BotonNav('Videos', Seccion.videos, indice, onNavegar),
          _BotonNav('Juegos', Seccion.juegos, indice, onNavegar),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: escritorio ? 240 : 170),
                child: _CajaBusqueda(
                  texto: 'Buscar títulos y juegos',
                  seleccionada: indice == Seccion.buscar,
                  onTap: () => onNavegar(Seccion.buscar),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const _BotonNotificaciones(),
          const SizedBox(width: 4),
          AvatarUsuario(onTap: () => onNavegar(Seccion.perfil)),
        ],
      ),
    );
  }
}

class _BotonNav extends StatelessWidget {
  final String texto;
  final int destino;
  final int actual;
  final ValueChanged<int> onNavegar;

  const _BotonNav(this.texto, this.destino, this.actual, this.onNavegar);

  @override
  Widget build(BuildContext context) {
    final activo = destino == actual;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: activo ? UColores.tarjetaClara : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onNavegar(destino),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                color: UColores.texto,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CajaBusqueda extends StatelessWidget {
  final String texto;
  final bool seleccionada;
  final VoidCallback onTap;

  const _CajaBusqueda({
    required this.texto,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: UColores.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: seleccionada ? UColores.azul : UColores.borde,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 15, color: UColores.textoSuave),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: UColores.textoSuave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonNotificaciones extends StatelessWidget {
  const _BotonNotificaciones();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notificaciones',
      icon: const Icon(Icons.notifications_none, size: 20),
      color: UColores.texto,
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No tienes notificaciones nuevas')),
          );
      },
    );
  }
}

// Cabecera del formato móvil.
class CabeceraMovil extends StatelessWidget {
  final ValueChanged<int> onNavegar;

  const CabeceraMovil({super.key, required this.onNavegar});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 16, right: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: UColores.borde)),
      ),
      child: Row(
        children: [
          const LogoUditflix(tamano: 21),
          const Spacer(),
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search, size: 20),
            onPressed: () => onNavegar(Seccion.buscar),
          ),
          const _BotonNotificaciones(),
          const SizedBox(width: 4),
          AvatarUsuario(onTap: () => onNavegar(Seccion.perfil)),
        ],
      ),
    );
  }
}

// Barra de navegación inferior del formato móvil (5 accesos).
class BarraInferior extends StatelessWidget {
  final int indice;
  final ValueChanged<int> onNavegar;

  const BarraInferior({
    super.key,
    required this.indice,
    required this.onNavegar,
  });

  static const _accesos = [
    (Icons.home_outlined, 'Inicio'),
    (Icons.movie_outlined, 'Videos'),
    (Icons.sports_esports_outlined, 'Juegos'),
    (Icons.search, 'Buscar'),
    (Icons.person_outline, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: UColores.panel,
        border: Border(top: BorderSide(color: UColores.borde)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < _accesos.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onNavegar(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _accesos[i].$1,
                          size: 21,
                          color: i == indice
                              ? UColores.azulClaro
                              : UColores.textoSuave,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _accesos[i].$2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                i == indice ? FontWeight.w700 : FontWeight.w500,
                            color: i == indice
                                ? UColores.texto
                                : UColores.textoSuave,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
