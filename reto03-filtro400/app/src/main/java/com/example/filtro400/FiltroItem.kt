package com.example.filtro400

/**
 * Modelo de datos (Data Class) que representa un filtro de llamadas individual.
 * Contiene la información necesaria almacenada en la base de datos SQLite.
 */
data class FiltroItem(
    val id: Long,        // Identificador único autoincremental en SQLite (Primary Key).
    val prefijo: String, // El prefijo telefónico objeto del bloqueo (ej. "400").
    val activo: Boolean, // Estado del filtro: true si está activo, false si está desactivado.
    val creadoEn: Long   // Marca de tiempo (timestamp en ms) de cuándo se creó el registro.
)
