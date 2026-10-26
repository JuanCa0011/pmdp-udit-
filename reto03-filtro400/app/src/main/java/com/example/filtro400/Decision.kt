package com.example.filtro400

/**
 * Estructura de datos que encapsula el resultado de la evaluación del motor de filtrado.
 */
data class Decision(
    val permitir: Boolean,  // true si la llamada pasa, false si se bloquea.
    val tipoRegla: String,  // Categoría de la regla aplicada ("WHITELIST", "BLOCKED", "PREFIX", "DEFAULT").
    val reglaRef: String    // Referencia específica de la regla que tomó la decisión.
)
