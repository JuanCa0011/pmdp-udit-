
//
// ARCHIVO PRINCIPAL DE UDITFLIX
//
// Este archivo inicia nuestra aplicación Flutter.
//
// Desde aquí indicamos cuál será la primera pantalla
// que verá el usuario y el tema visual de la aplicación.
//

import 'package:flutter/material.dart';

import 'screens/principal_screen.dart';
import 'theme/uditflix_theme.dart';

// Función principal.
// En Dart, main() es el punto de entrada del programa.

void main() {

  // Ejecutamos la aplicación Flutter.
  runApp(const UDITflixApp());

}

// Widget principal de la aplicación.
// MaterialApp proporciona los componentes visuales
// y la configuración general de nuestra aplicación.

class UDITflixApp extends StatelessWidget {

  const UDITflixApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      // Quitamos la etiqueta de depuración.
      debugShowCheckedModeBanner: false,

      // Nombre de la aplicación.
      title: 'UDITflix',

      // Tema oscuro con acentos rojo y azul neón.
      theme: temaUditflix(),

      // Primera pantalla: navegación con Inicio, Videos y Juegos.
      home: const PrincipalScreen(),

    );
  }
}
