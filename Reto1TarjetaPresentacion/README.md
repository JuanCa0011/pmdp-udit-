# 🎴 Reto 1: Tarjeta de Presentación Digital (Android)

[![Kotlin](https://img.shields.io/badge/Kotlin-1.9+-7F52FF.svg?style=flat&logo=kotlin&logoColor=white)](https://kotlinlang.org/)
[![Jetpack Compose](https://img.shields.io/badge/Jetpack%20Compose-Material%203-4285F4.svg?style=flat&logo=android&logoColor=white)](https://developer.android.com/jetpack/compose)
[![Android SDK](https://img.shields.io/badge/Min%20SDK-24-3DDC84.svg?style=flat&logo=android&logoColor=white)](https://developer.android.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Aplicación nativa para Android desarrollada como parte del **Reto 1 de la asignatura Programación Multimedia y Dispositivos Móviles (PMDM - UDIT)**. Se trata de una **Tarjeta de Presentación Interactiva (Business Card App)** construida utilizando **Jetpack Compose** y los principios de diseño de **Material Design 3**.

---

## 🚀 Características Principales

- **🎨 Interfaz Moderna y Declarativa**: Diseñada íntegramente con Jetpack Compose y adaptada al sistema de temas de Material Design 3.
- **🖼️ Imagen de Perfil Personalizada**:
  - Renderizado de imagen con recorte circular mediante `Modifier.clip(CircleShape)`.
  - Ajuste proporcional de contenido sin deformación con `ContentScale.Crop`.
- **🔗 Integración con Aplicaciones Externas (Intents Implícitos)**:
  - **Perfil de GitHub**: Abre directamente el perfil del desarrollador en el navegador mediante `Intent.ACTION_VIEW`.
  - **Perfil de LinkedIn**: Acceso directo al perfil profesional de LinkedIn.
  - **Envío de Correo Electrónico**: Abre el cliente de correo predeterminado configurado en el dispositivo mediante un intent `mailto:` (`ACTION_SENDTO`).
- **📂 Gestión Segura de Archivos con FileProvider**:
  - Configuración de `FileProvider` e inclusión de `file_paths.xml` para intercambio y gestión segura de archivos de caché en el dispositivo.
- **📱 Vista Previa en Tiempo Real**:
  - Soporte completo para vista previa (`@Preview`) dentro de Android Studio sin necesidad de desplegar en dispositivo físico o emulador.

---

## 🛠️ Tecnologías y Herramientas

| Tecnología | Descripción |
| :--- | :--- |
| **Kotlin** | Lenguaje de programación principal para Android. |
| **Jetpack Compose** | Toolkit moderno de UI declarativa para Android. |
| **Material 3** | Última versión del sistema de diseño de Google (Componentes, Colores, Tipografías). |
| **Android Intents** | Mecanismo para comunicación entre componentes y lanzamiento de apps externas. |
| **AndroidX FileProvider** | Subclase de `ContentProvider` para compartir de forma segura archivos basados en URI `content://`. |

---

## 📂 Estructura Detallada del Proyecto

```text
Reto1TarjetaPresentacion/
├── gradle/
│   ├── wrapper/
│   │   ├── gradle-wrapper.jar          # Binario ejecutable del wrapper de Gradle
│   │   └── gradle-wrapper.properties   # Configuración de versión de Gradle
│   └── libs.versions.toml              # Catálogo de versiones de dependencias (Version Catalog)
├── app/                                # Módulo principal de la aplicación Android
│   ├── src/
│   │   ├── main/                       # Código fuente y recursos de producción
│   │   │   ├── java/com/example/reto1_tarjetapresentacion/
│   │   │   │   ├── MainActivity.kt     # Punto de entrada principal y Composables de la tarjeta
│   │   │   │   └── ui/theme/           # Sistema de temas e identidad visual Material 3
│   │   │   │       ├── Color.kt        # Definición de la paleta de colores (Primary, Secondary, Dark/Light)
│   │   │   │       ├── Theme.kt        # Composable de tema con soporte para Dynamic Color
│   │   │   │       └── Type.kt         # Estilos tipográficos (Headings, Body, Labels)
│   │   │   ├── res/                    # Recursos de la interfaz de usuario
│   │   │   │   ├── drawable/           # Imágenes vectoriales y mapas de bits
│   │   │   │   │   ├── foto_perfil.jpg # Fotografía de perfil utilizada en la tarjeta
│   │   │   │   │   └── logoapp.jpg     # Logotipo de la aplicación
│   │   │   │   ├── mipmap-*/           # Iconos de la aplicación en múltiples resoluciones (hdpi a xxxhdpi)
│   │   │   │   ├── values/             # Constantes y valores XML
│   │   │   │   │   ├── colors.xml      # Colores definidos en XML
│   │   │   │   │   ├── strings.xml     # Cadenas de texto internacionalizadas
│   │   │   │   │   └── themes.xml      # Tema base de la Activity
│   │   │   │   └── xml/                # Archivos XML de configuración de Android
│   │   │   │       ├── backup_rules.xml# Reglas de copia de seguridad de Android
│   │   │   │       ├── data_extraction_rules.xml # Reglas de extracción de datos en Android 12+
│   │   │   │       └── file_paths.xml  # Configuración de rutas expuestas para FileProvider
│   │   │   ├── AndroidManifest.xml     # Manifest: Declaración de componentes, permisos y FileProvider
│   │   │   └── ic_launcher-playstore.png # Icono en alta resolución para publicación
│   │   ├── test/                       # Pruebas unitarias locales (JVM)
│   │   │   └── java/com/example/reto1_tarjetapresentacion/
│   │   │       └── ExampleUnitTest.kt  # Test unitario básico
│   │   └── androidTest/                # Pruebas de instrumentación en dispositivo/emulador
│   │       └── java/com/example/reto1_tarjetapresentacion/
│   │           └── ExampleInstrumentedTest.kt # Test de integración en entorno Android
│   ├── build.gradle.kts                # Configuración de construcción del módulo app (plugins, dependencias)
│   └── .gitignore                      # Reglas de exclusión de Git específicas del módulo app
├── build.gradle.kts                    # Script de construcción raíz del proyecto Gradle
├── settings.gradle.kts                 # Configuración de repositorios y módulos del proyecto
├── gradle.properties                   # Propiedades globales de la JVM y Gradle
├── gradlew / gradlew.bat               # Scripts ejecutables para Gradle Wrapper (Linux/Mac y Windows)
├── .gitignore                          # Reglas globales de Git
└── README.md                           # Documentación técnica del proyecto
```

### 🔍 Desglose de Componentes Clave

1. **`MainActivity.kt`**:
   - Actividad principal (`ComponentActivity`).
   - Contiene la función Composable `TarjetaPresentacion()`.
   - Implementa la lógica de **intents implícitos** para la navegación hacia URLs externas (GitHub, LinkedIn) y lanzamiento del cliente de correo electrónico (`mailto:`).
2. **Sistema de Temas (`ui/theme/`)**:
   - Centraliza la apariencia visual usando **Material Design 3**.
   - `Theme.kt` aplica colores dinámicos según el sistema y configura la paleta para modos claro y oscuro.
   - `Color.kt` y `Type.kt` definen la identidad de colores y tipografías.
3. **`AndroidManifest.xml` y `file_paths.xml`**:
   - Configura la Activity con filtro de intenciones para inicio.
   - Registra el `androidx.core.content.FileProvider` apuntando a `file_paths.xml` para compartir recursos/archivos de forma segura.
4. **Catálogo de Versiones (`gradle/libs.versions.toml`)**:
   - Gestor centralizado de versiones y librerías (Jetpack Compose, Material3, AndroidX Core, etc.).

---

## 📝 Explicación del Código Principal

La lógica de la interfaz reside en la función Composable `TarjetaPresentacion` dentro de [`MainActivity.kt`](app/src/main/java/com/example/reto1_tarjetapresentacion/MainActivity.kt):

```kotlin
@Composable
fun TarjetaPresentacion() {
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(all = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Foto de Perfil Circular
        Image(
            painter = painterResource(id = R.drawable.foto_perfil),
            contentDescription = "Foto de perfil de usuario",
            modifier = Modifier
                .size(150.dp)
                .clip(CircleShape),
            contentScale = ContentScale.Crop
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Nombre y Cargo
        Text(text = "Juan Giménez", fontSize = 32.sp, fontWeight = FontWeight.Bold)
        Text(text = "Software Engineer", fontSize = 18.sp, color = MaterialTheme.colorScheme.secondary)

        Spacer(modifier = Modifier.height(32.dp))

        // Botón GitHub
        Button(
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/JuanCa0011"))
                context.startActivity(intent)
            },
            modifier = Modifier.fillMaxWidth(fraction = 0.8f)
        ) {
            Text(text = "Mi Perfil de GitHub")
        }

        // Botón LinkedIn
        Button(
            onClick = {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.linkedin.com/in/juan-gim%C3%A9nez-a84844155/"))
                context.startActivity(intent)
            },
            modifier = Modifier.fillMaxWidth(fraction = 0.8f)
        ) {
            Text(text = "Mi Perfil de LinkedIn")
        }

        // Botón Correo Electrónico
        Button(
            onClick = {
                val intent = Intent(Intent.ACTION_SENDTO).apply {
                    data = Uri.parse("mailto:juan-carlos7900@hotmail.com")
                }
                context.startActivity(intent)
            },
            modifier = Modifier.fillMaxWidth(fraction = 0.8f)
        ) {
            Text(text = "Enviar E-mail")
        }
    }
}
```

---

## ⚙️ Configuración del Entorno de Desarrollo

### Requisitos Previos
- **Android Studio**: Ladybug / Iguana o superior.
- **JDK**: Versión 17 recomendada.
- **Android SDK**:
  - Compile SDK: 34 o superior.
  - Min SDK: 24 (Android 7.0 Nougat).

### Pasos para Ejecutar el Proyecto

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/JuanCa0011/Reto1-TarjetaPresentacion.git
   cd Reto1-TarjetaPresentacion
   ```
2. **Abrir en Android Studio**:
   - Inicia Android Studio y selecciona **Open**.
   - Navega hasta la carpeta del proyecto clonado y acéptala.
3. **Sincronizar Gradle**:
   - Deja que Android Studio descargue las dependencias y sincronice el proyecto automáticamente.
4. **Ejecutar la App**:
   - Conecta un dispositivo físico con Depuración USB activada o inicia un Emulador (AVD).
   - Presiona el botón **Run (`Shift + F10`)**.

---

## 👤 Autor

- **Juan Giménez**
  - **GitHub**: [@JuanCa0011](https://github.com/JuanCa0011)
  - **LinkedIn**: [Juan Giménez](https://www.linkedin.com/in/juan-gim%C3%A9nez-a84844155/)
  - **Email**: `juan-carlos7900@hotmail.com`

---

## 📜 Licencia

Este proyecto se distribuye bajo la licencia MIT. Puedes consultar más detalles en el archivo `LICENSE`.
