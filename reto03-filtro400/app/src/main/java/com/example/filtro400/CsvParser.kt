package com.example.filtro400

/**
 * Resultado de la operación de importación de CSV, indicando métricas y errores.
 */
data class CsvImportResult(
    val importados: Int,
    val rechazados: Int,
    val errores: List<String>
)

/**
 * Parser de dominio puro para exportar e importar configuraciones en formato CSV (`tipo;valor;alias;activo`).
 */
object CsvParser {

    /**
     * Exporta todas las reglas actuales a un string con formato CSV.
     */
    fun exportarCsv(
        filtros: List<FiltroItem>,
        bloqueados: List<NumeroBloqueadoItem>,
        whitelist: List<ListaBlancaItem>
    ): String {
        val sb = StringBuilder()
        sb.append("tipo;valor;alias;activo\n")
        for (f in filtros) {
            sb.append("prefijo;${f.prefijo};Prioridad ${f.prioridad};${if (f.activo) 1 else 0}\n")
        }
        for (b in bloqueados) {
            sb.append("bloqueado;${b.numeroNormalizado};${b.alias.orEmpty()};${if (b.activo) 1 else 0}\n")
        }
        for (w in whitelist) {
            sb.append("blanca;${w.numeroNormalizado};${w.alias.orEmpty()};1\n")
        }
        return sb.toString()
    }

    /**
     * Importa reglas desde un contenido CSV de forma tolerante a fallos, validando cada línea.
     */
    fun importarCsv(
        contenido: String,
        repository: FiltroRepository
    ): CsvImportResult {
        var importados = 0
        var rechazados = 0
        val errores = mutableListOf<String>()

        val lineas = contenido.lines()
        for ((index, linea) in lineas.withIndex()) {
            val trimmed = linea.trim()
            if (trimmed.isEmpty() || trimmed.startsWith("tipo;")) continue

            val partes = trimmed.split(";")
            if (partes.size < 2) {
                rechazados++
                errores.add("Línea ${index + 1}: Formato inválido")
                continue
            }

            val tipo = partes[0].trim().lowercase()
            val valor = partes[1].trim()
            val alias = if (partes.size > 2 && partes[2].trim().isNotEmpty()) partes[2].trim() else null

            try {
                when (tipo) {
                    "prefijo" -> {
                        val res = repository.insertarFiltro(valor, 0)
                        if (res.isSuccess) importados++ else {
                            rechazados++
                            errores.add("Línea ${index + 1}: Prefijo duplicado o inválido ($valor)")
                        }
                    }
                    "bloqueado" -> {
                        val res = repository.insertarNumeroBloqueado(valor, alias)
                        if (res.isSuccess) importados++ else {
                            rechazados++
                            errores.add("Línea ${index + 1}: Número bloqueado duplicado o inválido ($valor)")
                        }
                    }
                    "blanca", "whitelist" -> {
                        val res = repository.insertarWhitelist(valor, alias)
                        if (res.isSuccess) importados++ else {
                            rechazados++
                            errores.add("Línea ${index + 1}: Lista blanca duplicada o inválida ($valor)")
                        }
                    }
                    else -> {
                        rechazados++
                        errores.add("Línea ${index + 1}: Tipo desconocido '$tipo'")
                    }
                }
            } catch (e: Exception) {
                rechazados++
                errores.add("Línea ${index + 1}: ${e.localizedMessage}")
            }
        }

        return CsvImportResult(importados, rechazados, errores)
    }
}
