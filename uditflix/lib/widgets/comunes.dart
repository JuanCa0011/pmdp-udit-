//
// COMPONENTES VISUALES COMUNES
//
// Piezas pequeñas que se repiten en todas las pantallas:
// logotipo, insignias, etiquetas, chips, botones, imágenes...
//

import 'package:flutter/material.dart';

import '../theme/uditflix_theme.dart';

// Logotipo UDITFLIX en azul.
class LogoUditflix extends StatelessWidget {
  final double tamano;

  const LogoUditflix({super.key, this.tamano = 22});

  @override
  Widget build(BuildContext context) {
    return Text(
      'UDITFLIX',
      style: UTextos.titular(tamano, color: UColores.azul),
    );
  }
}

// Título pequeño de sección: "DESTACADOS Y RECOMENDADOS".
class TituloSeccion extends StatelessWidget {
  final String texto;

  const TituloSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 2.5,
          fontWeight: FontWeight.w600,
          color: UColores.textoSuave,
        ),
      ),
    );
  }
}

// Cabecera de página: antetítulo de color + titular grande.
class CabeceraPagina extends StatelessWidget {
  final String antetitulo;
  final String titulo;
  final Color color;
  final double tamano;

  const CabeceraPagina({
    super.key,
    required this.antetitulo,
    required this.titulo,
    required this.color,
    this.tamano = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(antetitulo.toUpperCase(), style: UTextos.antetitulo(color)),
        const SizedBox(height: 6),
        Text(titulo.toUpperCase(), style: UTextos.titular(tamano)),
      ],
    );
  }
}

// Insignia: ESTRENO, GRATIS, INCLUIDO, NUEVO, DESTACADO...
class Insignia extends StatelessWidget {
  final String texto;
  final Color color;

  // true: fondo de color sólido. false: contorno con fondo translúcido.
  final bool relleno;

  const Insignia(
    this.texto, {
    super.key,
    this.color = UColores.azul,
    this.relleno = false,
  });

  // Color habitual de cada insignia del diseño.
  factory Insignia.de(String texto, {bool relleno = false}) {
    final color = switch (texto) {
      'ESTRENO' || 'NUEVO' || 'DESTACADO' => UColores.rojo,
      'INCLUIDO' => UColores.textoSuave,
      _ => UColores.azulClaro,
    };
    return Insignia(texto, color: color, relleno: relleno);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: relleno ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
        border: relleno
            ? null
            : Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: relleno ? Colors.white : color,
        ),
      ),
    );
  }
}

// Etiqueta gris pequeña (Clásico, 1 jugador, 16+...).
class Etiqueta extends StatelessWidget {
  final String texto;

  const Etiqueta(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: UColores.tarjetaClara,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 10.5, color: UColores.textoSuave),
      ),
    );
  }
}

// Fila de etiquetas en una sola línea (se recorta si no cabe).
class FilaEtiquetas extends StatelessWidget {
  final List<String> etiquetas;

  const FilaEtiquetas(this.etiquetas, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: etiquetas.length,
        separatorBuilder: (_, _) => const SizedBox(width: 5),
        itemBuilder: (_, i) => Center(child: Etiqueta(etiquetas[i])),
      ),
    );
  }
}

// Chip de filtro con forma de píldora (Todo, Acción, Terror...).
class ChipFiltro extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final Color color;
  final VoidCallback onTap;

  const ChipFiltro({
    super.key,
    required this.texto,
    required this.seleccionado,
    required this.onTap,
    this.color = UColores.rojo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado ? color : UColores.panel,
      shape: StadiumBorder(
        side: BorderSide(color: seleccionado ? color : UColores.borde),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: seleccionado ? Colors.white : UColores.texto,
            ),
          ),
        ),
      ),
    );
  }
}

// Fila de chips: en horizontal con scroll o en varias líneas.
class FilaChips extends StatelessWidget {
  final List<String> opciones;
  final String seleccionada;
  final ValueChanged<String> onSeleccion;
  final Color color;
  final bool envolver;

  const FilaChips({
    super.key,
    required this.opciones,
    required this.seleccionada,
    required this.onSeleccion,
    this.color = UColores.rojo,
    this.envolver = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final o in opciones)
        ChipFiltro(
          texto: o,
          seleccionado: o == seleccionada,
          color: color,
          onTap: () => onSeleccion(o),
        ),
    ];

    if (envolver) {
      return Wrap(spacing: 6, runSpacing: 8, children: chips);
    }

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) => Center(child: chips[i]),
      ),
    );
  }
}

// Botón rectangular de UDITflix (JUGAR, REPRODUCIR, PRÓXIMAMENTE...).
class BotonUdit extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback? onPressed;

  // false: estilo gris apagado (PRÓXIMAMENTE).
  final bool principal;
  final Color color;
  final bool compacto;

  const BotonUdit(
    this.texto, {
    super.key,
    this.icono,
    this.onPressed,
    this.principal = true,
    this.color = UColores.rojo,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final fondo = principal ? color : UColores.tarjetaClara;
    final colorTexto = principal ? Colors.white : UColores.textoSuave;

    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compacto ? 12 : 18,
            vertical: compacto ? 7 : 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Icon(icono, size: compacto ? 14 : 18, color: colorTexto),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  texto.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compacto ? 10.5 : 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: colorTexto,
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

// Avatar del usuario: cuadrado con degradado morado-rojo.
class AvatarUsuario extends StatelessWidget {
  final double tamano;
  final VoidCallback? onTap;

  const AvatarUsuario({super.key, this.tamano = 28, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tamano,
        height: tamano,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tamano * 0.22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), UColores.rojo],
          ),
        ),
        child: Text(
          'U',
          style: TextStyle(
            fontSize: tamano * 0.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Imagen de Internet con carga y alternativa si falla la red.
class ImagenRed extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ImagenRed(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progreso) {
        if (progreso == null) return child;
        return const _FondoImagen();
      },
      errorBuilder: (context, error, stack) =>
          const _FondoImagen(icono: Icons.image_not_supported_outlined),
    );
  }
}

class _FondoImagen extends StatelessWidget {
  final IconData? icono;

  const _FondoImagen({this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1630), Color(0xFF1A0A12)],
        ),
      ),
      child: icono == null
          ? null
          : Center(child: Icon(icono, color: UColores.textoTenue)),
    );
  }
}

// Pie de página.
class PieUditflix extends StatelessWidget {
  final bool apilado;

  const PieUditflix({super.key, this.apilado = false});

  @override
  Widget build(BuildContext context) {
    const texto = Text(
      'Videos y juegos en un solo lugar. © 2026 UDITFLIX',
      style: TextStyle(fontSize: 11, color: UColores.textoSuave),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: UColores.borde)),
      ),
      child: apilado
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [LogoUditflix(), SizedBox(height: 6), texto],
            )
          : const Row(
              children: [
                LogoUditflix(),
                Spacer(),
                Flexible(child: texto),
              ],
            ),
    );
  }
}

// Aviso para los juegos que todavía no están disponibles.
void avisarProximamente(BuildContext context, String titulo) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$titulo llegará pronto a UDIT Arcade')),
    );
}
