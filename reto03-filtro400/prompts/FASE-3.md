Haz la FASE 3 (sigue las reglas de AGENTS.md): sistema completo de filtrado.
Hazla en sub-pasos (3A, 3B, 3C...) con build verde y commit en cada uno.

OBLIGATORIO
1. NÚMEROS BLOQUEADOS: tabla `numero_bloqueado` (número normalizado, alias
   opcional, activo). CRUD en UI. Coincidencia exacta tras normalizar.
2. LISTAS BLANCAS: tabla `lista_blanca` (número normalizado, alias). CRUD en UI.
3. GESTIÓN AVANZADA DE FILTROS: campo `prioridad INTEGER` en los filtros por
   prefijo (migración de BD v2->v3 sin perder datos). Reordenación en UI.
4. RESOLUCIÓN DE CONFLICTOS (documentar en código y en DECISIONES.md). Orden
   determinista:
   a) Lista blanca exacta -> PERMITIR (siempre gana).
   b) Número bloqueado exacto -> BLOQUEAR.
   c) Prefijos activos por prioridad (mayor primero; desempate por id) ->
      primera coincidencia decide.
   d) Sin coincidencia -> PERMITIR.
   `Decision` incluye motivo y id/tipo de la regla que decidió.
5. REGISTRO DE ACTIVIDAD: tabla `registro(id, momento, numero_enmascarado,
   decision, tipo_regla, regla_ref)`. PRIVACIDAD: guarda el número ENMASCARADO
   (p. ej. "+34400****56"), nunca completo ni nombres de contactos. Retención
   configurable (p. ej. borrar >30 días) y botón de vaciar registro. Las
   escrituras del registro van en hilo de fondo DESPUÉS de responder a Android.
6. IMPORT/EXPORT CSV con Storage Access Framework (CreateDocument /
   OpenDocument), sin permisos de almacenamiento. Formato documentado:
   `tipo;valor;alias;activo` (tipo = bloqueado|blanca|prefijo). Importación
   tolerante: valida cada línea, ignora duplicados, informa de filas
   importadas/rechazadas y por qué. Parser en dominio puro.
7. ESTADÍSTICAS: pantalla con total de bloqueadas, permitidas y bloqueos por
   regla (top reglas), con consultas SQL agregadas (GROUP BY) sobre `registro`.
8. SIMULADOR DE LLAMADAS: pantalla donde se escribe un número y se muestra la
   decisión paso a paso (qué regla y por qué). La simulación NO se escribe en
   el registro real (o se marca como simulada).

OPCIONALES (solo si lo anterior está terminado y estable)
- Números ocultos: regla activable (vacío -> bloquear si el usuario lo activa;
  por defecto permitir).
- Bloqueo por franja horaria en filtros por prefijo.
- Exportación de estadísticas a CSV.

RENDIMIENTO
Caché en memoria de TODAS las reglas (whitelist y bloqueados en HashSet,
prefijos ordenados), rehecha tras cualquier escritura. Índices SQLite en las
columnas de búsqueda. Cero consultas SQL en la ruta caliente de `onScreenCall`,
salvo la carga inicial de la caché.

NAVEGACIÓN
Compose Navigation o NavigationBar con: Filtros, Bloqueados, Lista blanca,
Registro, Estadísticas, Simulador, Import/Export.

TESTS
Motor completo (precedencia whitelist > bloqueado > prefijo > prioridad,
empates, inactivos, vacío, internacionales), enmascarado de números, parser CSV
(válido, líneas rotas, duplicados, separadores), migraciones si es viable.
Entregables en `entregas/fase3/` y tag `fase-3`.
