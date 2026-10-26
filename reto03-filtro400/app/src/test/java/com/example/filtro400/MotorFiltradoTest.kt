package com.example.filtro400

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class MotorFiltradoTest {

    private val filtrosActivos = listOf("400", "900", "800")

    @Test
    fun bloqueaPrefijoExacto() {
        assertTrue(MotorFiltrado.decidir("400123456", filtrosActivos))
    }

    @Test
    fun bloqueaConPrefijoPais() {
        assertTrue(MotorFiltrado.decidir("+34400123456", filtrosActivos))
        assertTrue(MotorFiltrado.decidir("0034400123456", filtrosActivos))
        assertTrue(MotorFiltrado.decidir("+34 900 111 222", filtrosActivos))
    }

    @Test
    fun noBloqueaNumeroPermitido() {
        assertFalse(MotorFiltrado.decidir("612345678", filtrosActivos))
        assertFalse(MotorFiltrado.decidir("912345678", filtrosActivos))
    }

    @Test
    fun ignoraFiltrosInactivosOmitidos() {
        val sin800 = listOf("400")
        assertFalse(MotorFiltrado.decidir("800123456", sin800))
    }

    @Test
    fun manejaListaFiltrosVacia() {
        assertFalse(MotorFiltrado.decidir("400123456", emptyList()))
    }

    @Test
    fun validaPrefijosCorrectamente() {
        assertTrue(MotorFiltrado.validarPrefijo("400").isSuccess)
        assertTrue(MotorFiltrado.validarPrefijo("").isFailure)
    }
}
