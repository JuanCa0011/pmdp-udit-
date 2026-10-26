package com.example.filtro400

/**
 * Modelo de datos (Data Class) que representa una entrada en el historial de llamadas interceptadas.
 */
data class RegistroItem(
    val id: Long,                 // Identificador único autoincremental en SQLite.
    val momento: Long,            // Timestamp de cuándo ocurrió la llamada.
    val numeroEnmascarado: String,// Número protegido por privacidad (ej. "+344****56").
    val decision: String,         // Resultado: "BLOQUEADA" o "PERMITIDA".
    val tipoRegla: String,        // Tipo de regla que decidió ("WHITELIST", "BLOCKED", "PREFIX", "DEFAULT").
    val reglaRef: String          // Detalle de la regla o valor que provocó la decisión.
)
