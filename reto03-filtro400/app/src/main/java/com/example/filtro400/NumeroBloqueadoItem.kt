package com.example.filtro400

/**
 * Modelo de datos (Data Class) que representa un número de teléfono exacto bloqueado.
 */
data class NumeroBloqueadoItem(
    val id: Long,                 // Identificador único autoincremental en SQLite.
    val numeroNormalizado: String,// Número telefónico limpio listo para comparación exacta.
    val alias: String?,           // Descripción o nombre opcional (ej. "Spam comercial").
    val activo: Boolean,          // Si el bloqueo está activo o desactivado.
    val creadoEn: Long            // Marca de tiempo de cuándo fue añadido.
)
