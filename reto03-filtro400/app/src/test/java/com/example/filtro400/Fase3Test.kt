package com.example.filtro400

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class Fase3Test {

    @Test
    fun pruebaEnmascaramiento() {
        assertEquals("+344****56", MotorFiltrado.enmascararNumero("+34400123456"))
        assertEquals("6001****89", MotorFiltrado.enmascararNumero("600123489"))
        assertEquals("****", MotorFiltrado.enmascararNumero("123"))
    }

    @Test
    fun precedenciaConflictoWhitelistGanaSiempre() {
        val numero = "600123456"
        val whitelist = setOf(numero)
        val blocked = setOf(numero)
        val prefixes = listOf(FiltroItem(1L, "600", true, 10, 0L))

        val decision = MotorFiltrado.decidirDetallado(numero, whitelist, blocked, prefixes)
        assertTrue(decision.permitir)
        assertEquals("WHITELIST", decision.tipoRegla)
    }

    @Test
    fun precedenciaConflictoBloqueadoGanaAPrefijo() {
        val numero = "600123456"
        val whitelist = emptySet<String>()
        val blocked = setOf(numero)
        val prefixes = listOf(FiltroItem(1L, "600", true, 10, 0L))

        val decision = MotorFiltrado.decidirDetallado(numero, whitelist, blocked, prefixes)
        assertFalse(decision.permitir)
        assertEquals("BLOCKED", decision.tipoRegla)
    }

    @Test
    fun evaluacionPrefijosPorPrioridad() {
        val numero = "400123456"
        val whitelist = emptySet<String>()
        val blocked = emptySet<String>()
        val prefixes = listOf(
            FiltroItem(1L, "400", true, 5, 0L),
            FiltroItem(2L, "4001", true, 10, 0L)
        )

        val decision = MotorFiltrado.decidirDetallado(numero, whitelist, blocked, prefixes)
        assertFalse(decision.permitir)
        assertEquals("PREFIX", decision.tipoRegla)
        assertTrue(decision.reglaRef.contains("4001"))
    }

    @Test
    fun exportarEImportarCsvFormatoCorrecto() {
        val filtros = listOf(FiltroItem(1L, "400", true, 0, 0L))
        val bloqueados = listOf(NumeroBloqueadoItem(1L, "600123456", "Spam", true, 0L))
        val whitelist = listOf(ListaBlancaItem(1L, "600999888", "Familia", 0L))

        val csv = CsvParser.exportarCsv(filtros, bloqueados, whitelist)
        assertTrue(csv.contains("prefijo;400"))
        assertTrue(csv.contains("bloqueado;600123456"))
        assertTrue(csv.contains("blanca;600999888"))
    }
}
