//
// PANTALLA PRINCIPAL (ESTRUCTURA DE NAVEGACIÓN)
//
// Contiene las secciones Inicio, Videos, Juegos, Buscar y Perfil.
// - Escritorio y tablet: cabecera superior con navegación y buscador.
// - Móvil: cabecera compacta y barra inferior con 5 accesos.
//
// IndexedStack conserva el estado de cada sección
// (por ejemplo, la partida de Tres en Raya) al cambiar de pestaña.
//

import 'package:flutter/material.dart';

import '../utils/responsive.dart';
import '../widgets/navegacion.dart';
import 'buscar_screen.dart';
import 'catalogo_screen.dart';
import 'inicio_screen.dart';
import 'juegos_screen.dart';
import 'perfil_screen.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final GlobalKey<JuegosScreenState> _claveJuegos = GlobalKey();

  int _indice = Seccion.inicio;
  String _categoriaVideos = 'Todo';

  void _navegar(int indice) => setState(() => _indice = indice);

  // Desde "Explorar por categoría": Videos filtrado o la tienda de juegos.
  void _abrirCategoria(String categoria) {
    setState(() {
      if (categoria == 'Juegos') {
        _indice = Seccion.juegos;
      } else {
        _categoriaVideos = categoria;
        _indice = Seccion.videos;
      }
    });
  }

  // Lleva al panel "Juega aquí mismo" de la tienda.
  void _irATresEnRaya() {
    setState(() => _indice = Seccion.juegos);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _claveJuegos.currentState?.irATresEnRaya(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formato = Responsive.de(context);
    final movil = formato == Formato.movil;

    final secciones = IndexedStack(
      index: _indice,
      children: [
        InicioScreen(
          onNavegar: _navegar,
          onAbrirCategoria: _abrirCategoria,
          irATresEnRaya: _irATresEnRaya,
        ),
        CatalogoScreen(
          categoria: _categoriaVideos,
          onCategoria: (c) => setState(() => _categoriaVideos = c),
          onIrAJuegos: () => _navegar(Seccion.juegos),
        ),
        JuegosScreen(key: _claveJuegos),
        BuscarScreen(irATresEnRaya: _irATresEnRaya),
        const PerfilScreen(),
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (movil)
              CabeceraMovil(onNavegar: _navegar)
            else
              CabeceraAncha(
                indice: _indice,
                onNavegar: _navegar,
                formato: formato,
              ),
            Expanded(child: secciones),
          ],
        ),
      ),
      bottomNavigationBar:
          movil ? BarraInferior(indice: _indice, onNavegar: _navegar) : null,
    );
  }
}
