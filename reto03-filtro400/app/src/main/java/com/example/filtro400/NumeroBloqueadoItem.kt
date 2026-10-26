package com.example.filtro400

data class NumeroBloqueadoItem(
    val id: Long,
    val numeroNormalizado: String,
    val alias: String?,
    val activo: Boolean,
    val creadoEn: Long
)
