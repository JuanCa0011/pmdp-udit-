package com.example.filtro400

data class RegistroItem(
    val id: Long,
    val momento: Long,
    val numeroEnmascarado: String,
    val decision: String, // "BLOQUEADA" o "PERMITIDA"
    val tipoRegla: String, // "WHITELIST", "BLOCKED", "PREFIX", "DEFAULT"
    val reglaRef: String
)
