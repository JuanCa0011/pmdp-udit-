
//
// PRUEBAS DE LA APLICACIÓN UDITFLIX
//
// - La aplicación se construye sin desbordamientos en los tres
//   formatos del diseño: escritorio (1440), tablet (834) y móvil (390).
// - La navegación lleva a Videos, Juegos y a la ficha de una película.
// - La lógica del Tres en Raya detecta ganadores y la CPU bloquea.
// - El videojuego Neon Flap arranca y responde a las pulsaciones.
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uditflix/arcade/neon_flap_game.dart';
import 'package:uditflix/main.dart';
import 'package:uditflix/screens/neon_flap_screen.dart';
import 'package:uditflix/theme/uditflix_theme.dart';
import 'package:uditflix/widgets/tres_en_raya.dart';

// Ajusta el tamaño lógico de la pantalla de pruebas.
void usarPantalla(WidgetTester tester, Size tamano) {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {

  const formatos = {
    'escritorio': Size(1440, 900),
    'tablet': Size(834, 1194),
    'móvil': Size(390, 844),
  };

  for (final formato in formatos.entries) {
    testWidgets('UDITflix se muestra en ${formato.key}', (tester) async {
      usarPantalla(tester, formato.value);

      await tester.pumpWidget(const UDITflixApp());
      await tester.pump();

      expect(find.text('UDITFLIX'), findsWidgets);
      expect(find.text('DESTACADOS Y RECOMENDADOS'), findsOneWidget);

      // Recorremos las secciones principales: en móvil con la barra
      // inferior (último en el árbol) y en el resto con la cabecera.
      final movil = formato.key == 'móvil';
      Finder nav(String texto) =>
          movil ? find.text(texto).last : find.text(texto).first;

      await tester.tap(nav('Videos'));
      await tester.pumpAndSettle();
      expect(find.text('PERSECUCIÓN NEÓN'), findsWidgets);

      await tester.tap(nav('Juegos'));
      await tester.pumpAndSettle();
      expect(find.text('JUEGA AQUÍ MISMO'), findsOneWidget);
      expect(find.text('TU TURNO (X)'), findsOneWidget);
    });
  }

  testWidgets('Desde Videos se abre la ficha y su botón Reproducir',
      (tester) async {
    usarPantalla(tester, const Size(390, 844));

    await tester.pumpWidget(const UDITflixApp());
    await tester.tap(find.text('Videos').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('LA CASA ROJA').first);
    await tester.pumpAndSettle();

    expect(find.text('REPRODUCIR'), findsOneWidget);
    expect(find.text('88% para ti'), findsOneWidget);
  });

  group('Lógica del Tres en Raya', () {
    test('detecta una línea ganadora', () {
      final tablero = <String?>['X', 'X', 'X', null, 'O', 'O', null, null, null];
      expect(ganadorTresEnRaya(tablero), 'X');
    });

    test('sin línea completa no hay ganador', () {
      final tablero = <String?>['X', 'O', 'X', null, 'O', null, null, null, null];
      expect(ganadorTresEnRaya(tablero), isNull);
    });

    test('la CPU gana si puede', () {
      final tablero = <String?>['O', 'O', null, 'X', 'X', null, null, null, null];
      expect(jugadaCpu(tablero), 2);
    });

    test('la CPU bloquea al jugador', () {
      final tablero = <String?>['X', 'X', null, null, 'O', null, null, null, null];
      expect(jugadaCpu(tablero), 2);
    });
  });

  testWidgets('Se puede jugar una jugada contra la CPU', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: temaUditflix(),
      home: const Scaffold(body: SingleChildScrollView(child: TresEnRaya())),
    ));

    // Pulsamos la primera casilla del tablero.
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    expect(find.text('PIENSA LA CPU...'), findsOneWidget);

    // La CPU responde tras un pequeño retardo.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('TU TURNO (X)'), findsOneWidget);
  });

  testWidgets('Neon Flap arranca y empieza al pulsar', (tester) async {
    usarPantalla(tester, const Size(390, 844));

    await tester.pumpWidget(MaterialApp(
      theme: temaUditflix(),
      home: const NeonFlapScreen(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PULSA PARA VOLAR'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // La primera pulsación inicia la partida y oculta el mensaje.
    await tester.tapAt(tester.getCenter(find.byType(NeonFlapScreen)));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('PULSA PARA VOLAR'), findsNothing);

    // Sin más pulsaciones el personaje cae y aparece Game Over.
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('GAME OVER'), findsOneWidget);
    expect(NeonFlapGame.mejorPuntuacion, 0);

    // Reiniciar vuelve a mostrar el mensaje de inicio.
    await tester.tap(find.text('REINICIAR'));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('GAME OVER'), findsNothing);
    expect(find.text('PULSA PARA VOLAR'), findsOneWidget);

    // Desmontamos el juego para cerrar sus temporizadores.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
