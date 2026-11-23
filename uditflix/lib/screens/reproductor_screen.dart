
//
// PANTALLA DEL REPRODUCTOR
//
// Reproduce el vídeo MP4 del contenido con el paquete video_player.
//
// Controles:
// - Tocar el vídeo muestra u oculta los controles.
// - Reproducir / pausar, retroceder y avanzar 10 segundos.
// - Barra de progreso en la que se puede arrastrar.
// - Silenciar el sonido.
// - Pantalla completa (horizontal y sin barras del sistema).
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/contenido.dart';
import '../theme/uditflix_theme.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';

class ReproductorScreen extends StatefulWidget {

  // Contenido que queremos visualizar.
  final Contenido contenido;

  const ReproductorScreen({
    super.key,
    required this.contenido,
  });

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<ReproductorScreen> {

  late VideoPlayerController _controlador;
  bool _cargando = true;
  String? _error;
  bool _controlesVisibles = true;
  bool _pantallaCompleta = false;
  Timer? _temporizadorControles;

  @override
  void initState() {
    super.initState();
    _iniciarVideo();
  }

  // Crea el controlador con la URL del vídeo y lo prepara.
  Future<void> _iniciarVideo() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    _controlador = VideoPlayerController.networkUrl(
      Uri.parse(widget.contenido.videoUrl),
    );
    _controlador.addListener(_alCambiarVideo);

    try {
      await _controlador.initialize();
      if (!mounted) return;
      setState(() => _cargando = false);
      await _controlador.play();
      _programarOcultarControles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se ha podido cargar el vídeo.\nComprueba tu conexión a Internet.';
      });
    }
  }

  void _alCambiarVideo() {
    if (!mounted) return;
    // Al terminar el vídeo volvemos a mostrar los controles.
    final v = _controlador.value;
    if (v.isInitialized && !v.isPlaying && v.position >= v.duration) {
      _controlesVisibles = true;
    }
    setState(() {});
  }

  Future<void> _reintentar() async {
    _controlador.removeListener(_alCambiarVideo);
    await _controlador.dispose();
    await _iniciarVideo();
  }

  @override
  void dispose() {
    _temporizadorControles?.cancel();
    _controlador.removeListener(_alCambiarVideo);
    _controlador.dispose();
    _restaurarSistema();
    super.dispose();
  }

  // ---- Controles ----

  void _programarOcultarControles() {
    _temporizadorControles?.cancel();
    _temporizadorControles = Timer(const Duration(seconds: 3), () {
      if (mounted && _controlador.value.isPlaying) {
        setState(() => _controlesVisibles = false);
      }
    });
  }

  void _alternarControles() {
    setState(() => _controlesVisibles = !_controlesVisibles);
    if (_controlesVisibles) _programarOcultarControles();
  }

  void _reproducirPausar() {
    final v = _controlador.value;
    if (v.isPlaying) {
      _controlador.pause();
      _temporizadorControles?.cancel();
    } else {
      // Si había terminado, empezamos desde el principio.
      if (v.position >= v.duration) _controlador.seekTo(Duration.zero);
      _controlador.play();
      _programarOcultarControles();
    }
  }

  void _saltar(int segundos) {
    final v = _controlador.value;
    var destino = v.position + Duration(seconds: segundos);
    if (destino < Duration.zero) destino = Duration.zero;
    if (destino > v.duration) destino = v.duration;
    _controlador.seekTo(destino);
    _programarOcultarControles();
  }

  void _alternarSonido() {
    _controlador.setVolume(_controlador.value.volume > 0 ? 0 : 1);
  }

  // ---- Pantalla completa ----

  Future<void> _alternarPantallaCompleta() async {
    final entrar = !_pantallaCompleta;
    setState(() => _pantallaCompleta = entrar);

    if (entrar) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await _restaurarSistema();
    }
  }

  Future<void> _restaurarSistema() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  // ---- Interfaz ----

  @override
  Widget build(BuildContext context) {
    // En pantalla completa, "atrás" sale de pantalla completa.
    return PopScope(
      canPop: !_pantallaCompleta,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _pantallaCompleta) _alternarPantallaCompleta();
      },
      child: _pantallaCompleta ? _vistaPantallaCompleta() : _vistaNormal(),
    );
  }

  Widget _vistaPantallaCompleta() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: _video()),
    );
  }

  Widget _vistaNormal() {
    final formato = Responsive.de(context);
    final c = widget.contenido;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          c.titulo.toUpperCase(),
          style: UTextos.titular(20),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: EdgeInsets.all(formato == Formato.movil ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(formato == Formato.movil ? 0 : 8),
                    child: _video(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(formato == Formato.movil ? 16 : 0)
                        .copyWith(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REPRODUCIENDO',
                            style: UTextos.antetitulo(UColores.rojo)),
                        const SizedBox(height: 6),
                        Text(c.titulo.toUpperCase(), style: UTextos.titular(28)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Etiqueta(c.tipo),
                            Etiqueta(c.categoria),
                            Etiqueta(c.edad),
                            Etiqueta(c.duracion),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(c.descripcion, style: UTextos.cuerpo),
                        const SizedBox(height: 14),
                        const Text(
                          'Vídeo MP4 de demostración reproducido desde Internet.',
                          style: TextStyle(fontSize: 11, color: UColores.textoTenue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Zona de vídeo con sus controles superpuestos.
  Widget _video() {
    final v = _controlador.value;
    final proporcion =
        v.isInitialized && v.aspectRatio > 0 ? v.aspectRatio : 16 / 9;

    return AspectRatio(
      aspectRatio: proporcion,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (v.isInitialized) VideoPlayer(_controlador),
            if (_cargando)
              const Center(
                child: CircularProgressIndicator(color: UColores.rojo),
              ),
            if (_error != null) _vistaError(),
            if (v.isInitialized && _error == null) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _alternarControles,
              ),
              IgnorePointer(
                ignoring: !_controlesVisibles,
                child: AnimatedOpacity(
                  opacity: _controlesVisibles ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: _controles(v),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vistaError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: UColores.textoSuave, size: 36),
          const SizedBox(height: 10),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: UColores.textoSuave),
          ),
          const SizedBox(height: 12),
          BotonUdit('Reintentar', icono: Icons.refresh, compacto: true, onPressed: _reintentar),
        ],
      ),
    );
  }

  Widget _controles(VideoPlayerValue v) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _alternarControles,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x55000000), Color(0x11000000), Color(0xCC000000)],
          ),
        ),
        child: Column(
          children: [
            const Spacer(),

            // Retroceder, reproducir/pausar y avanzar.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BotonControl(
                  icono: Icons.replay_10_rounded,
                  tooltip: 'Retroceder 10 s',
                  onPressed: () => _saltar(-10),
                ),
                const SizedBox(width: 18),
                _BotonControl(
                  icono: v.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  tooltip: v.isPlaying ? 'Pausar' : 'Reproducir',
                  grande: true,
                  onPressed: _reproducirPausar,
                ),
                const SizedBox(width: 18),
                _BotonControl(
                  icono: Icons.forward_10_rounded,
                  tooltip: 'Avanzar 10 s',
                  onPressed: () => _saltar(10),
                ),
              ],
            ),

            const Spacer(),

            // Barra de progreso.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: VideoProgressIndicator(
                _controlador,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                colors: const VideoProgressColors(
                  playedColor: UColores.rojo,
                  bufferedColor: Color(0x55FFFFFF),
                  backgroundColor: Color(0x22FFFFFF),
                ),
              ),
            ),

            // Tiempo, sonido y pantalla completa.
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 4, 4),
              child: Row(
                children: [
                  Text(
                    '${_formatear(v.position)} / ${_formatear(v.duration)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: v.volume > 0 ? 'Silenciar' : 'Activar sonido',
                    color: Colors.white,
                    icon: Icon(v.volume > 0
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded),
                    onPressed: _alternarSonido,
                  ),
                  IconButton(
                    tooltip: _pantallaCompleta
                        ? 'Salir de pantalla completa'
                        : 'Pantalla completa',
                    color: Colors.white,
                    icon: Icon(_pantallaCompleta
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded),
                    onPressed: _alternarPantallaCompleta,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatear(Duration d) {
    String dos(int n) => n.toString().padLeft(2, '0');
    final horas = d.inHours;
    final minutos = d.inMinutes.remainder(60);
    final segundos = d.inSeconds.remainder(60);
    return horas > 0
        ? '$horas:${dos(minutos)}:${dos(segundos)}'
        : '${dos(minutos)}:${dos(segundos)}';
  }
}

class _BotonControl extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback onPressed;
  final bool grande;

  const _BotonControl({
    required this.icono,
    required this.tooltip,
    required this.onPressed,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: grande ? UColores.rojo : Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        iconSize: grande ? 38 : 26,
        color: Colors.white,
        icon: Icon(icono),
        onPressed: onPressed,
      ),
    );
  }
}
