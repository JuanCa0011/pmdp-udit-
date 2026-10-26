package com.example.filtro400

/**
 * Motor de filtrado avanzado para la Fase 3: resolución determinista de conflictos
 * (Lista Blanca > Números Bloqueados > Prefijos por Prioridad), enmascaramiento y normalización.
 */
object MotorFiltrado {

    fun normalizar(numero: String): String {
        val limpio = numero.filter { it.isDigit() || it == '+' }
        return when {
            limpio.startsWith("+34") -> limpio.removePrefix("+34")
            limpio.startsWith("0034") -> limpio.removePrefix("0034")
            else -> limpio
        }
    }

    /**
     * Enmascara un número telefónico para proteger la privacidad en el registro de actividad.
     * Ejemplo: "+34400123456" -> "+344****56"
     */
    fun enmascararNumero(numero: String): String {
        if (numero.length <= 6) return "****"
        val inicio = numero.take(4)
        val fin = numero.takeLast(2)
        return "$inicio****$fin"
    }

    /**
     * Resolución de conflictos determinista:
     * 1. Lista blanca exacta -> Permitir (gana siempre).
     * 2. Número bloqueado exacto -> Bloquear.
     * 3. Prefijos activos ordenados por prioridad descendente (empate por ID descendente) -> Primera coincidencia decide.
     * 4. Por defecto -> Permitir.
     */
    fun decidirDetallado(
        numero: String,
        whitelist: Set<String>,
        blocked: Set<String>,
        prefixRules: List<FiltroItem>
    ): Decision {
        if (numero.isBlank()) {
            return Decision(permitir = true, tipoRegla = "DEFAULT", reglaRef = "Número vacío")
        }

        val numeroNorm = normalizar(numero)

        // 1. Lista Blanca
        if (whitelist.contains(numeroNorm)) {
            return Decision(permitir = true, tipoRegla = "WHITELIST", reglaRef = numeroNorm)
        }

        // 2. Número Bloqueado Exacto
        if (blocked.contains(numeroNorm)) {
            return Decision(permitir = false, tipoRegla = "BLOCKED", reglaRef = numeroNorm)
        }

        // 3. Prefijos ordenados por prioridad DESC, luego ID DESC
        val reglasOrdenadas = prefixRules.sortedWith(compareByDescending<FiltroItem> { it.prioridad }.thenByDescending { it.id })
        for (regla in reglasOrdenadas) {
            if (regla.activo) {
                val prefLimpio = regla.prefijo.filter { it.isDigit() || it == '+' }
                if (prefLimpio.isNotBlank() && numeroNorm.startsWith(prefLimpio)) {
                    return Decision(
                        permitir = false,
                        tipoRegla = "PREFIX",
                        reglaRef = "Prefijo ${regla.prefijo} (Prioridad ${regla.prioridad})"
                    )
                }
            }
        }

        // 4. Por defecto: Permitir
        return Decision(permitir = true, tipoRegla = "DEFAULT", reglaRef = "Sin coincidencia")
    }

    // Compatibilidad con llamadas antiguas que solo piden Boolean
    fun decidir(numero: String, filtrosActivos: List<String>): Boolean {
        val dummyRules = filtrosActivos.mapIndexed { index, pref ->
            FiltroItem(id = index.toLong(), prefijo = pref, activo = true, prioridad = 0, creadoEn = 0L)
        }
        val decision = decidirDetallado(numero, emptySet(), emptySet(), dummyRules)
        return !decision.permitir
    }

    fun validarPrefijo(prefijo: String): Result<String> {
        val limpio = prefijo.filter { it.isDigit() }
        return when {
            limpio.isBlank() -> Result.failure(IllegalArgumentException("El prefijo no puede estar vacío."))
            limpio.length > 15 -> Result.failure(IllegalArgumentException("El prefijo es demasiado largo."))
            else -> Result.success(limpio)
        }
    }
}
