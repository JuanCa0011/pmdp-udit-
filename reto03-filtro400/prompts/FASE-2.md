Haz la FASE 2 (sigue las reglas de AGENTS.md): prefijos configurables en SQLite.

Funcionalidad:
- Tabla `filtro(id INTEGER PK AUTOINCREMENT, prefijo TEXT NOT NULL UNIQUE,
  activo INTEGER NOT NULL DEFAULT 1, creado_en INTEGER NOT NULL)`.
  Prefijo validado (solo dígitos, no vacío, longitud razonable).
- CRUD completo desde la UI: añadir, editar, eliminar, activar/desactivar con
  Switch individual, lista con `LazyColumn`.
- Los filtros se cargan al iniciar la app. Si la tabla está vacía en la primera
  instalación, inserta el prefijo "400" como semilla.
- El servicio usa los filtros almacenados (ya no hay prefijo hardcodeado).

Diseño:
- `FiltroRepository` sobre SQLiteOpenHelper (migraciones por `onUpgrade`).
- Caché en memoria de filtros ACTIVOS (lista inmutable en un `@Volatile`) que
  el repositorio actualiza tras cada escritura. El servicio lee SOLO de la
  caché; si está vacía (proceso recién creado) la carga una vez de SQLite con
  bloqueo mínimo y la guarda. Un cambio de filtro se aplica a la siguiente
  llamada sin reiniciar nada.
- `MotorFiltrado.decidir(numero, filtros): Decision` en dominio puro.
- UI con ViewModel + StateFlow; mantén el banner de estado del rol y el
  probador de números (ahora con el motor real y los filtros de BD).

Tests: JVM para el motor (varios prefijos, inactivos ignorados, normalización,
vacío) y validación. Entregables en `entregas/fase2/` y tag `fase-2`.
Al terminar, resume y espera mi "continúa".
