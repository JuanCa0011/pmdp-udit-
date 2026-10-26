package com.example.filtro400

/**
 * Modelo de datos (Data Class) que representa un número en la lista blanca
 * (exento de cualquier regla de bloqueo).
 */
data class ListaBlancaItem(
    val id: Long,                 // Identificador único autoincremental en SQLite.
    val numeroNormalizado: String,// Número limpio exento de bloqueo.
    val alias: String?,           // Descripción opcional (ej. "Familia", "Hospital").
    val creadoEn: Long            // Marca de tiempo de creación.
)
