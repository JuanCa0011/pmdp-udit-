package com.example.filtro400

data class Decision(
    val permitir: Boolean,
    val tipoRegla: String, // "WHITELIST", "BLOCKED", "PREFIX", "DEFAULT"
    val reglaRef: String
)
