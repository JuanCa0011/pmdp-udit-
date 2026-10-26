# Plan de Implementación - Fase 3: Sistema Completo de Filtrado

## Descripción del Objetivo
Ampliar la aplicación con listas blancas, números bloqueados individuales, gestión avanzada de filtros con prioridades, resolución determinista de conflictos, registro de actividad con privacidad (números enmascarados), exportación/importación CSV con Storage Access Framework, estadísticas y un simulador interactivo de llamadas.

## User Review Required
- **Navegación**: Se implementará una barra de navegación inferior (Bottom Navigation) o pestañas deslizables (Tabs) para acceder cómodamente a las 7 secciones (Filtros, Bloqueados, Lista Blanca, Registro, Estadísticas, Simulador, Import/Export).
- **Base de datos**: Migración de SQLite v2 a v3 añadiendo la columna `prioridad` en `filtro`, y creando las tablas `numero_bloqueado`, `lista_blanca` y `registro`.

## Open Questions
- Ninguna. Los requerimientos están definidos con precisión en el prompt de la Fase 3.

## Proposed Changes

### Componente 1: Base de Datos y Repositorio (`FiltroRepository`)
- **[MODIFY]** [FiltroRepository.kt](file:///C:/Users/JUANCA/Documents/pmdm (asignatura)/dam-android/pmdm-udit/reto03-filtro400/app/src/main/java/com/example/filtro400/FiltroRepository.kt)
  - Actualizar versión de BD a 3 (`DATABASE_VERSION = 3`).
  - Añadir tablas:
    - `numero_bloqueado`: `id INTEGER PK AUTOINCREMENT, numero_normalizado TEXT NOT NULL UNIQUE, alias TEXT, activo INTEGER DEFAULT 1, creado_en INTEGER`
    - `lista_blanca`: `id INTEGER PK AUTOINCREMENT, numero_normalizado TEXT NOT NULL UNIQUE, alias TEXT, creado_en INTEGER`
    - `registro`: `id INTEGER PK AUTOINCREMENT, momento INTEGER, numero_enmascarado TEXT, decision TEXT, tipo_regla TEXT, regla_ref TEXT`
  - Añadir columna `prioridad INTEGER DEFAULT 0` a la tabla `filtro` en `onUpgrade`.
  - Implementar caché en memoria optimizada: `HashSet` para lista blanca, `HashSet` para bloqueados exactos, y `List<FiltroItem>` ordenada por prioridad descendente y ID.
  - Añadir métodos de inserción en segundo plano para el registro de actividad y limpieza por retención (ej. >30 días).

### Componente 2: Dominio y Lógica (`MotorFiltrado`, `CsvParser`)
- **[MODIFY]** [MotorFiltrado.kt](file:///C:/Users/JUANCA/Documents/pmdm (asignatura)/dam-android/pmdm-udit/reto03-filtro400/app/src/main/java/com/example/filtro400/MotorFiltrado.kt)
  - Estructura `Decision(val permitir: Boolean, val tipoRegla: String, val reglaRef: String)`.
  - Lógica de resolución de conflictos determinista:
    1. Lista blanca exacta -> Permitir.
    2. Número bloqueado exacto -> Bloquear.
    3. Prefijos activos ordenados por prioridad descendente (empate por ID) -> Primera coincidencia decide.
    4. Por defecto -> Permitir.
  - Función de enmascaramiento de números para privacidad (ej. `+34400****56`).
- **[NEW]** [CsvParser.kt](file:///C:/Users/JUANCA/Documents/pmdm (asignatura)/dam-android/pmdm-udit/reto03-filtro400/app/src/main/java/com/example/filtro400/CsvParser.kt)
  - Parser robusto y tolerante en dominio puro para importar/exportar formato `tipo;valor;alias;activo`.

### Componente 3: ViewModel (`FiltroViewModel`)
- **[MODIFY]** [FiltroViewModel.kt](file:///C:/Users/JUANCA/Documents/pmdm (asignatura)/dam-android/pmdm-udit/reto03-filtro400/app/src/main/java/com/example/filtro400/FiltroViewModel.kt)
  - Estados para listas blancas, números bloqueados, registro de actividad, estadísticas y simulación.
  - Métodos CRUD completos para cada entidad y lógica de importación/exportación CSV.

### Componente 4: Interfaz de Usuario y Navegación (`MainActivity` y pantallas)
- **[MODIFY]** [MainActivity.kt](file:///C:/Users/JUANCA/Documents/pmdm (asignatura)/dam-android/pmdm-udit/reto03-filtro400/app/src/main/java/com/example/filtro400/MainActivity.kt)
  - Implementar navegación por pestañas o Bottom Navigation para:
    1. Prefijos (con control de prioridad)
    2. Números Bloqueados
    3. Lista Blanca
    4. Registro de Actividad (con botón de vaciar)
    5. Estadísticas (gráficas/métricas con GROUP BY)
    6. Simulador de Llamadas
    7. Importar / Exportar CSV (usando Storage Access Framework)

### Componente 5: Pruebas Unitarias
- **[NEW]** `MotorFiltradoTest.kt` ampliado con tests para precedencia (whitelist > blocked > prefix priority), enmascarado y CSV parser.

## Verification Plan

### Automated Tests
- Ejecutar pruebas unitarias JVM: `./gradlew testDebugUnitTest`

### Manual Verification
- Desplegar la app en emulador/dispositivo y verificar:
  - CRUD de listas blancas y números bloqueados.
  - Cambio de prioridad en prefijos y comportamiento en llamadas.
  - Enmascaramiento correcto en el registro de actividad.
  - Importación y exportación de archivos CSV.
  - Estadísticas y simulador de llamadas.
