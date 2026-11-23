//
// PANTALLA DE BÚSQUEDA
//
// Busca películas, series y juegos por título o categoría.
//

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/elemento_catalogo.dart';
import '../theme/uditflix_theme.dart';
import '../utils/abrir.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';
import '../widgets/fila_elemento.dart';

class BuscarScreen extends StatefulWidget {
  final VoidCallback irATresEnRaya;

  const BuscarScreen({super.key, required this.irATresEnRaya});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  String _consulta = '';

  List<ElementoCatalogo> get _resultados {
    final todos = [
      ...contenidos.map(ElementoCatalogo.video),
      ...juegos.map(ElementoCatalogo.juego),
    ];
    final q = _consulta.trim().toLowerCase();
    if (q.isEmpty) return todos;
    return todos
        .where((e) =>
            e.titulo.toLowerCase().contains(q) ||
            e.subtitulo.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final formato = Responsive.de(context);
    final margen = Responsive.margen(formato);
    final resultados = _resultados;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: EdgeInsets.fromLTRB(margen, 24, margen, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CabeceraPagina(
                  antetitulo: 'Buscar',
                  titulo: 'Títulos y juegos',
                  color: UColores.azulClaro,
                  tamano: formato == Formato.movil ? 32 : 44,
                ),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (v) => setState(() => _consulta = v),
                  style: const TextStyle(color: UColores.texto),
                  decoration: InputDecoration(
                    hintText: 'Persecución, terror, arcade...',
                    hintStyle: const TextStyle(color: UColores.textoTenue),
                    prefixIcon: const Icon(Icons.search, color: UColores.textoSuave),
                    filled: true,
                    fillColor: UColores.panel,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: UColores.borde),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: UColores.azul),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TituloSeccion('${resultados.length} resultados'),
                for (final e in resultados)
                  FilaElemento(
                    elemento: e,
                    onTap: () => abrirElemento(context, e,
                        irATresEnRaya: widget.irATresEnRaya),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
