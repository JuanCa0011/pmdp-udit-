package com.example.filtro400

/**
 * Modelo de datos (Data Class) que representa un filtro de prefijo.
 * Ampliado en Fase 3 con el campo 'prioridad' para la gestión avanzada.
 */
data class FiltroItem(
    val id: Long,
    val prefijo: String,
    val activo: Boolean,
    val prioridad: Int = 0, // Mayor número = mayor prioridad en la evaluación
    val creadoEn: Long
)
