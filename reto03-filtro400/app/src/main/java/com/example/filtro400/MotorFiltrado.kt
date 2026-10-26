package com.example.filtro400

/**
 * Motor de dominio puro encargado de la lógica de normalización de números telefónicos,
 * validación de prefijos y la decisión de bloqueo, completamente desacoplado de Android y bases de datos.
 */
object MotorFiltrado {

    /**
     * Normaliza un número telefónico eliminando espacios, guiones y prefijos internacionales de España.
     */
    fun normalizar(numero: String): String {
        // Se queda únicamente con los dígitos numéricos y el signo '+'
        val limpio = numero.filter { it.isDigit() || it == '+' }
        return when {
            limpio.startsWith("+34") -> limpio.removePrefix("+34")   // Remueve prefijo internacional +34
            limpio.startsWith("0034") -> limpio.removePrefix("0034") // Remueve prefijo internacional 0034
            else -> limpio
        }
    }

    /**
     * Decide si un número debe ser bloqueado comprobando si coincide con alguno de los filtros activos.
     */
    fun decidir(numero: String, filtrosActivos: List<String>): Boolean {
        if (numero.isBlank() || filtrosActivos.isEmpty()) return false
        val numeroNormalizado = normalizar(numero)
        // Comprueba si el número normalizado empieza por alguno de los prefijos activos
        return filtrosActivos.any { prefijo ->
            val prefijoLimpio = prefijo.filter { it.isDigit() || it == '+' }
            prefijoLimpio.isNotBlank() && numeroNormalizado.startsWith(prefijoLimpio)
        }
    }

    /**
     * Valida que el texto introducido para un prefijo sea correcto (no vacío y solo dígitos).
     */
    fun validarPrefijo(prefijo: String): Result<String> {
        val limpio = prefijo.filter { it.isDigit() }
        return when {
            limpio.isBlank() -> Result.failure(IllegalArgumentException("El prefijo no puede estar vacío."))
            limpio.length > 15 -> Result.failure(IllegalArgumentException("El prefijo es demasiado largo."))
            else -> Result.success(limpio)
        }
    }
}
