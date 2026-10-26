# Resumen Fase 2: Configuración de filtros y almacenamiento en SQLite

## Componentes Implementados
1. **Modelo de datos (`FiltroItem`)**: Representa un filtro con `id`, `prefijo`, `activo` y `creadoEn`.
2. **Motor de filtrado (`MotorFiltrado`)**: Lógica pura de dominio para normalizar números, validar prefijos y decidir si bloquear en base a la lista de filtros activos.
3. **Repositorio SQLite (`FiltroRepository`)**: Hereda de `SQLiteOpenHelper`, gestiona la tabla `filtro`, semilla inicial con `"400"`, caché en memoria `@Volatile` de filtros activos y operaciones CRUD seguras.
4. **ViewModel (`FiltroViewModel`)**: Administra el estado con `StateFlow` y expone métodos reactivos para la UI.
5. **Servicio (`FiltroLlamadasService`)**: Consulta los filtros activos desde el repositorio y aplica el filtrado real en llamadas entrantes.
6. **Interfaz Gráfica (`MainActivity` + Compose)**:
   - Banner de estado del rol de Call Screening.
   - Formulario para añadir nuevos prefijos validados.
   - `LazyColumn` con tarjetas para cada filtro, incluyendo `Switch` de activación, botón de edición y botón de eliminación.
   - Probador interactivo de números actualizado con el motor y los filtros reales de la base de datos.
7. **Pruebas Unitarias (`MotorFiltradoTest`)**: Pruebas JVM para múltiples prefijos, normalización, filtros inactivos y validación.
