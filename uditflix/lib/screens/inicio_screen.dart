//
// PANTALLA DE INICIO · TIENDA Y DESTACADOS
//
// Escritorio: menú lateral de categorías + contenido.
// Tablet: el menú lateral pasa a una fila de chips; se mantiene
//         la lista con su panel de detalle en paralelo.
// Móvil: todo apilado a una columna, carruseles con scroll horizontal
//        y la lista sin panel de detalle.
//

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/elemento_catalogo.dart';
import '../theme/uditflix_theme.dart';
import '../utils/abrir.dart';
import '../utils/responsive.dart';
import '../widgets/arte_neon.dart';
import '../widgets/comunes.dart';
import '../widgets/fila_elemento.dart';
import '../widgets/navegacion.dart';

class InicioScreen extends StatefulWidget {
  final ValueChanged<int> onNavegar;

  // Abre Videos (o Juegos) con la categoría indicada.
  final ValueChanged<String> onAbrirCategoria;
  final VoidCallback irATresEnRaya;

  const InicioScreen({
    super.key,
    required this.onNavegar,
    required this.onAbrirCategoria,
    required this.irATresEnRaya,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  static const List<String> _categorias = ['Todo', ...categoriasVideo, 'Juegos'];
  static const List<String> _pestanas = ['Novedades', 'Más populares', 'Juegos gratis'];

  String _categoria = 'Todo';
  int _pestana = 0;
  int _seleccionado = 0;

  // Elementos de la lista según la pestaña y la categoría elegidas.
  List<ElementoCatalogo> get _elementos {
    var videos = [...contenidos];
    if (_pestana == 1) {
      videos.sort((a, b) => b.valoracion.compareTo(a.valoracion));
    }

    final lista = [
      if (_pestana != 2) ...videos.map(ElementoCatalogo.video),
      ...juegos.map(ElementoCatalogo.juego),
    ];

    if (_categoria == 'Todo') return lista;
    if (_categoria == 'Juegos') return lista.where((e) => e.esJuego).toList();
    return lista
        .where((e) => !e.esJuego && e.contenido!.categoria == _categoria)
        .toList();
  }

  void _cambiarCategoria(String c) => setState(() {
        _categoria = c;
        _seleccionado = 0;
      });

  void _cambiarPestana(int p) => setState(() {
        _pestana = p;
        _seleccionado = 0;
      });

  void _abrir(ElementoCatalogo e) =>
      abrirElemento(context, e, irATresEnRaya: widget.irATresEnRaya);

  @override
  Widget build(BuildContext context) {
    final formato = Responsive.de(context);
    final margen = Responsive.margen(formato);

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSeccion('Destacados y recomendados'),
        _Carrusel(formato: formato, onAbrir: _abrir),
        const SizedBox(height: 32),
        const TituloSeccion('Especiales de la semana'),
        _Especiales(formato: formato, onAbrir: _abrir),
        const SizedBox(height: 32),
        _ListaConDetalle(
          formato: formato,
          pestanas: _pestanas,
          pestana: _pestana,
          onPestana: _cambiarPestana,
          elementos: _elementos,
          seleccionado: _seleccionado,
          onSeleccionar: (i) => setState(() => _seleccionado = i),
          onAbrir: _abrir,
        ),
        const SizedBox(height: 36),
        const TituloSeccion('Explorar por categoría'),
        _RejillaCategorias(
          formato: formato,
          onCategoria: widget.onAbrirCategoria,
        ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(margen, 16, margen, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BarraTienda(
                      formato: formato,
                      onNovedades: () => _cambiarPestana(0),
                      onBuscar: () => widget.onNavegar(Seccion.buscar),
                    ),
                    const SizedBox(height: 16),
                    if (formato == Formato.escritorio)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 170,
                            child: _MenuLateral(
                              categorias: _categorias,
                              categoria: _categoria,
                              pestana: _pestana,
                              onCategoria: _cambiarCategoria,
                              onPestana: _cambiarPestana,
                              onNavegar: widget.onNavegar,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: contenido),
                        ],
                      )
                    else ...[
                      FilaChips(
                        opciones: _categorias,
                        seleccionada: _categoria,
                        onSeleccion: _cambiarCategoria,
                      ),
                      const SizedBox(height: 18),
                      contenido,
                    ],
                  ],
                ),
              ),
            ),
          ),
          PieUditflix(apilado: formato == Formato.movil),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// BARRA DE LA TIENDA: Tu tienda · Novedades · Categorías · ...
// ---------------------------------------------------------------

class _BarraTienda extends StatelessWidget {
  final Formato formato;
  final VoidCallback onNovedades;
  final VoidCallback onBuscar;

  const _BarraTienda({
    required this.formato,
    required this.onNovedades,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    final opciones = <(String, VoidCallback?)>[
      ('Tu tienda', null),
      ('Novedades', onNovedades),
      ('Categorías', null),
      ('Puntos UDIT', null),
      ('Noticias', null),
    ];

    final enlaces = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < opciones.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Material(
              color: i == 0 ? const Color(0xFF233355) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: opciones[i].$2 ?? () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Text(
                    opciones[i].$1,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: UColores.texto,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111B30), Color(0xFF0C1322)],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF1C2A45)),
      ),
      child: formato == Formato.movil
          ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: enlaces)
          : Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: enlaces,
                  ),
                ),
                if (formato == Formato.escritorio) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: InkWell(
                      onTap: onBuscar,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1020),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF233355)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'buscar en la tienda',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: UColores.textoSuave),
                              ),
                            ),
                            Icon(Icons.search, size: 15, color: UColores.azulClaro),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------
// MENÚ LATERAL (solo escritorio)
// ---------------------------------------------------------------

class _MenuLateral extends StatelessWidget {
  final List<String> categorias;
  final String categoria;
  final int pestana;
  final ValueChanged<String> onCategoria;
  final ValueChanged<int> onPestana;
  final ValueChanged<int> onNavegar;

  const _MenuLateral({
    required this.categorias,
    required this.categoria,
    required this.pestana,
    required this.onCategoria,
    required this.onPestana,
    required this.onNavegar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECOMENDADO', style: UTextos.antetitulo(UColores.azulClaro)),
        const SizedBox(height: 8),
        _Opcion(Icons.auto_awesome_outlined, 'Novedades', pestana == 0, () => onPestana(0)),
        _Opcion(Icons.local_fire_department_outlined, 'Más populares', pestana == 1,
            () => onPestana(1)),
        _Opcion(Icons.card_giftcard_outlined, 'Juegos gratis', pestana == 2, () => onPestana(2)),
        const SizedBox(height: 22),
        Text('EXPLORAR CATEGORÍAS', style: UTextos.antetitulo(UColores.azulClaro)),
        const SizedBox(height: 8),
        for (final c in categorias)
          _Opcion(null, c, c == categoria, () => onCategoria(c), rojo: true),
        const SizedBox(height: 22),
        Text('ACCESOS', style: UTextos.antetitulo(UColores.azulClaro)),
        const SizedBox(height: 8),
        _Opcion(Icons.movie_outlined, 'Todas las películas', false,
            () => onNavegar(Seccion.videos)),
        _Opcion(Icons.tv_outlined, 'Series', false, () => onNavegar(Seccion.videos)),
        _Opcion(Icons.sports_esports_outlined, 'Tienda de juegos', false,
            () => onNavegar(Seccion.juegos)),
      ],
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData? icono;
  final String texto;
  final bool activa;
  final VoidCallback onTap;
  final bool rojo;

  const _Opcion(this.icono, this.texto, this.activa, this.onTap, {this.rojo = false});

  @override
  Widget build(BuildContext context) {
    // Las categorías se marcan con fondo rojo; los accesos solo en negrita.
    final fondo = activa && rojo ? const Color(0xFF3A0A10) : Colors.transparent;
    final color = activa && rojo ? const Color(0xFFFF5A6A) : UColores.textoSuave;

    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              if (icono != null) ...[
                Icon(icono, size: 14, color: activa ? UColores.texto : color),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: activa ? FontWeight.w700 : FontWeight.w500,
                    color: activa && !rojo ? UColores.texto : color,
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

// ---------------------------------------------------------------
// CARRUSEL DE DESTACADOS
// ---------------------------------------------------------------

class _Carrusel extends StatefulWidget {
  final Formato formato;
  final ValueChanged<ElementoCatalogo> onAbrir;

  const _Carrusel({required this.formato, required this.onAbrir});

  @override
  State<_Carrusel> createState() => _CarruselState();
}

class _CarruselState extends State<_Carrusel> {
  final PageController _paginas = PageController();
  int _pagina = 0;

  // Contenidos destacados: dos juegos gratis y dos estrenos.
  late final List<ElementoCatalogo> _destacados = [
    ElementoCatalogo.juego(juegos[0]),
    ElementoCatalogo.video(contenidos[0]),
    ElementoCatalogo.juego(juegos[1]),
    ElementoCatalogo.video(contenidos[1]),
  ];

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  void _mover(int delta) {
    final destino = (_pagina + delta) % _destacados.length;
    _paginas.animateToPage(
      destino,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formato = widget.formato;
    final alto = switch (formato) {
      Formato.escritorio => 330.0,
      Formato.tablet => 270.0,
      Formato.movil => 430.0,
    };

    return Column(
      children: [
        SizedBox(
          height: alto,
          child: Stack(
            children: [
              PageView.builder(
                controller: _paginas,
                itemCount: _destacados.length,
                onPageChanged: (p) => setState(() => _pagina = p),
                itemBuilder: (context, i) => _Diapositiva(
                  elemento: _destacados[i],
                  formato: formato,
                  onAbrir: () => widget.onAbrir(_destacados[i]),
                ),
              ),
              if (formato != Formato.movil) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Flecha(Icons.chevron_left, () => _mover(-1)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _Flecha(Icons.chevron_right, () => _mover(1)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Indicador de página.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _destacados.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _pagina ? 18 : 10,
                height: 3,
                color: i == _pagina ? UColores.rojo : UColores.borde,
              ),
          ],
        ),
      ],
    );
  }
}

class _Flecha extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;

  const _Flecha(this.icono, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 26,
          height: 52,
          child: Icon(icono, size: 18, color: UColores.texto),
        ),
      ),
    );
  }
}

class _Diapositiva extends StatelessWidget {
  final ElementoCatalogo elemento;
  final Formato formato;
  final VoidCallback onAbrir;

  const _Diapositiva({
    required this.elemento,
    required this.formato,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final imagen = GestureDetector(
      onTap: onAbrir,
      child: MiniaturaElemento(elemento),
    );

    // Cuatro miniaturas relacionadas (otros juegos u otros vídeos).
    final relacionados = elemento.esJuego
        ? juegos.where((j) => j != elemento.juego).take(4).map(ElementoCatalogo.juego).toList()
        : contenidos.where((c) => c != elemento.contenido).take(4).map(ElementoCatalogo.video).toList();

    final info = Container(
      color: const Color(0xFF0C1220),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            elemento.esJuego ? 'JUEGO GRATIS' : 'ESTRENO',
            style: UTextos.antetitulo(UColores.azulClaro),
          ),
          const SizedBox(height: 6),
          Text(
            elemento.titulo.toUpperCase(),
            maxLines: formato == Formato.movil ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: UTextos.titular(formato == Formato.tablet ? 19 : 23),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: formato == Formato.movil
                ? Row(
                    children: [
                      for (var i = 0; i < relacionados.length; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(child: _Mini(relacionados[i])),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      for (var fila = 0; fila < 2; fila++) ...[
                        if (fila > 0) const SizedBox(height: 4),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _Mini(relacionados[fila * 2])),
                              const SizedBox(width: 4),
                              Expanded(child: _Mini(relacionados[fila * 2 + 1])),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            elemento.esJuego ? 'Jugable ahora' : 'Disponible ahora',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UColores.texto,
            ),
          ),
          const SizedBox(height: 6),
          FilaEtiquetas(elemento.etiquetas),
          const SizedBox(height: 10),
          Row(
            children: [
              Insignia.de(elemento.esJuego ? 'GRATIS' : 'ESTRENO'),
              const Spacer(),
              BotonUdit(
                elemento.esJuego ? 'Jugar' : 'Ver',
                compacto: formato != Formato.escritorio,
                onPressed: onAbrir,
              ),
            ],
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: formato == Formato.movil
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 175, child: imagen),
                Expanded(child: info),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: imagen),
                SizedBox(
                  width: formato == Formato.escritorio ? 270 : 215,
                  child: info,
                ),
              ],
            ),
    );
  }
}

class _Mini extends StatelessWidget {
  final ElementoCatalogo elemento;

  const _Mini(this.elemento);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: MiniaturaElemento(elemento),
    );
  }
}

// ---------------------------------------------------------------
// ESPECIALES DE LA SEMANA
// ---------------------------------------------------------------

class _Especiales extends StatelessWidget {
  final Formato formato;
  final ValueChanged<ElementoCatalogo> onAbrir;

  const _Especiales({required this.formato, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    final especiales = [
      ElementoCatalogo.video(contenidos[1]),
      ElementoCatalogo.juego(juegos[1]),
      ElementoCatalogo.video(contenidos[0]),
    ];

    // Escritorio: tres tarjetas en fila. Tablet y móvil: scroll horizontal.
    if (formato == Formato.escritorio) {
      return SizedBox(
        height: 230,
        child: Row(
          children: [
            for (var i = 0; i < especiales.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: _TarjetaEspecial(especiales[i], onAbrir)),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: especiales.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: formato == Formato.tablet ? 240 : 220,
          child: _TarjetaEspecial(especiales[i], onAbrir),
        ),
      ),
    );
  }
}

class _TarjetaEspecial extends StatelessWidget {
  final ElementoCatalogo elemento;
  final ValueChanged<ElementoCatalogo> onAbrir;

  const _TarjetaEspecial(this.elemento, this.onAbrir);

  @override
  Widget build(BuildContext context) {
    final juego = elemento.esJuego;
    final subtitulo = juego
        ? 'Juego · ${elemento.juego!.jugando} jugando'
        : '${elemento.contenido!.tipo} · ${elemento.contenido!.duracion}';

    return Material(
      color: juego ? const Color(0xFF2A0910) : const Color(0xFF0E1A33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: juego ? const Color(0xFF5A1420) : const Color(0xFF1C2A45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onAbrir(elemento),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: MiniaturaElemento(elemento)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    elemento.titulo.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UTextos.titular(17),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitulo, style: UTextos.pequeno),
                  const SizedBox(height: 8),
                  Insignia(
                    juego ? 'GRATIS' : 'ESTRENO',
                    color: juego ? UColores.rojo : UColores.azul,
                    relleno: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// LISTA (Novedades / Más populares / Juegos gratis) + DETALLE
// ---------------------------------------------------------------

class _ListaConDetalle extends StatelessWidget {
  final Formato formato;
  final List<String> pestanas;
  final int pestana;
  final ValueChanged<int> onPestana;
  final List<ElementoCatalogo> elementos;
  final int seleccionado;
  final ValueChanged<int> onSeleccionar;
  final ValueChanged<ElementoCatalogo> onAbrir;

  const _ListaConDetalle({
    required this.formato,
    required this.pestanas,
    required this.pestana,
    required this.onPestana,
    required this.elementos,
    required this.seleccionado,
    required this.onSeleccionar,
    required this.onAbrir,
  });

  static const _iconos = [
    Icons.auto_awesome_outlined,
    Icons.local_fire_department_outlined,
    Icons.card_giftcard_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final movil = formato == Formato.movil;
    final indice = seleccionado.clamp(0, elementos.isEmpty ? 0 : elementos.length - 1);

    final pestanasWidget = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < pestanas.length; i++)
            Material(
              color: i == pestana ? UColores.tarjeta : Colors.transparent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: InkWell(
                onTap: () => onPestana(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(_iconos[i], size: 14,
                          color: i == pestana ? UColores.texto : UColores.textoSuave),
                      const SizedBox(width: 6),
                      Text(
                        pestanas[i],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: i == pestana ? FontWeight.w700 : FontWeight.w500,
                          color: i == pestana ? UColores.texto : UColores.textoSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final lista = elementos.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No hay contenidos en esta categoría', style: UTextos.cuerpo),
          )
        : Column(
            children: [
              for (var i = 0; i < elementos.length; i++)
                FilaElemento(
                  elemento: elementos[i],
                  seleccionado: !movil && i == indice,
                  // En móvil se abre directamente; en pantallas anchas
                  // el primer toque selecciona y muestra el detalle.
                  onTap: () {
                    if (movil || i == indice) {
                      onAbrir(elementos[i]);
                    } else {
                      onSeleccionar(i);
                    }
                  },
                ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pestanasWidget,
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: UColores.panel,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: movil || elementos.isEmpty
              ? lista
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: lista),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: formato == Formato.escritorio ? 230 : 180,
                      child: _PanelDetalle(
                        elemento: elementos[indice],
                        onAbrir: () => onAbrir(elementos[indice]),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _PanelDetalle extends StatelessWidget {
  final ElementoCatalogo elemento;
  final VoidCallback onAbrir;

  const _PanelDetalle({required this.elemento, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(elemento.titulo.toUpperCase(), style: UTextos.titular(22)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, size: 13, color: UColores.azulClaro),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  elemento.valoracion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: UColores.azulClaro,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [for (final e in elemento.etiquetas) Etiqueta(e)],
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: MiniaturaElemento(elemento),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            elemento.descripcion,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: UTextos.pequeno.copyWith(height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                elemento.esJuego ? Icons.people_outline : Icons.star,
                size: 13,
                color: UColores.rojo,
              ),
              const SizedBox(width: 5),
              Text(elemento.detalle, style: UTextos.pequeno),
            ],
          ),
          const SizedBox(height: 12),
          BotonUdit(
            elemento.esJuego ? 'Jugar' : 'Ver ficha',
            compacto: true,
            onPressed: onAbrir,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// EXPLORAR POR CATEGORÍA
// ---------------------------------------------------------------

class _RejillaCategorias extends StatelessWidget {
  final Formato formato;
  final ValueChanged<String> onCategoria;

  const _RejillaCategorias({required this.formato, required this.onCategoria});

  @override
  Widget build(BuildContext context) {
    final categorias = [...categoriasVideo, 'Juegos'];

    return GridView.count(
      crossAxisCount: Responsive.columnas(formato),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        for (var i = 0; i < categorias.length; i++)
          _TarjetaCategoria(
            nombre: categorias[i],
            rojo: i.isEven,
            onTap: () => onCategoria(categorias[i]),
          ),
      ],
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  final String nombre;
  final bool rojo;
  final VoidCallback onTap;

  const _TarjetaCategoria({
    required this.nombre,
    required this.rojo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Imagen de fondo: un vídeo de la categoría o el arte de un juego.
    final video = contenidos.where((c) => c.categoria == nombre);
    final fondo = video.isNotEmpty
        ? ImagenRed(video.first.imagenUrl)
        : ArteNeon(juegos.first.arte);

    final tinte = rojo ? const Color(0xFFB0101F) : const Color(0xFF1D3F9A);

    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            fondo,
            ColoredBox(color: tinte.withValues(alpha: 0.62)),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                nombre.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UTextos.titular(18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
