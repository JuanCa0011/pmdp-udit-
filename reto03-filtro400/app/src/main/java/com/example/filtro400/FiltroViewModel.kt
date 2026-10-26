package com.example.filtro400

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel ampliado para la Fase 3: gestiona el estado de prefijos con prioridad,
 * números bloqueados, lista blanca, registro de actividad, estadísticas y simulación.
 */
class FiltroViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = FiltroRepository.getInstance(application)

    private val _filtros = MutableStateFlow<List<FiltroItem>>(emptyList())
    val filtros: StateFlow<List<FiltroItem>> = _filtros.asStateFlow()

    private val _bloqueados = MutableStateFlow<List<NumeroBloqueadoItem>>(emptyList())
    val bloqueados: StateFlow<List<NumeroBloqueadoItem>> = _bloqueados.asStateFlow()

    private val _whitelist = MutableStateFlow<List<ListaBlancaItem>>(emptyList())
    val whitelist: StateFlow<List<ListaBlancaItem>> = _whitelist.asStateFlow()

    private val _logs = MutableStateFlow<List<RegistroItem>>(emptyList())
    val logs: StateFlow<List<RegistroItem>> = _logs.asStateFlow()

    private val _estadisticas = MutableStateFlow<Map<String, Any>>(emptyMap())
    val estadisticas: StateFlow<Map<String, Any>> = _estadisticas.asStateFlow()

    private val _mensajeError = MutableStateFlow<String?>(null)
    val mensajeError: StateFlow<String?> = _mensajeError.asStateFlow()

    init {
        cargarTodo()
        repository.limpiarLogsAntiguos(30)
    }

    fun cargarTodo() {
        viewModelScope.launch {
            _filtros.value = repository.getAllFilters()
            _bloqueados.value = repository.getAllBlockedNumbers()
            _whitelist.value = repository.getAllWhitelist()
            _logs.value = repository.getAllLogs()
            _estadisticas.value = repository.getEstadisticas()
        }
    }

    // CRUD Prefijos (con prioridad)
    fun agregarFiltro(prefijo: String, prioridad: Int) {
        viewModelScope.launch {
            repository.insertarFiltro(prefijo, prioridad).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al añadir filtro"
            }
        }
    }

    fun actualizarFiltro(id: Long, prefijo: String, activo: Boolean, prioridad: Int) {
        viewModelScope.launch {
            repository.actualizarFiltro(id, prefijo, activo, prioridad).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al actualizar filtro"
            }
        }
    }

    fun toggleFiltro(id: Long, activo: Boolean) {
        viewModelScope.launch {
            repository.toggleFiltro(id, activo).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al cambiar estado"
            }
        }
    }

    fun eliminarFiltro(id: Long) {
        viewModelScope.launch {
            repository.eliminarFiltro(id).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al eliminar filtro"
            }
        }
    }

    // CRUD Números Bloqueados
    fun agregarBloqueado(numero: String, alias: String?) {
        viewModelScope.launch {
            repository.insertarNumeroBloqueado(numero, alias).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al bloquear número"
            }
        }
    }

    fun toggleBloqueado(id: Long, activo: Boolean) {
        viewModelScope.launch {
            repository.toggleNumeroBloqueado(id, activo).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al cambiar estado"
            }
        }
    }

    fun eliminarBloqueado(id: Long) {
        viewModelScope.launch {
            repository.eliminarNumeroBloqueado(id).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al eliminar número bloqueado"
            }
        }
    }

    // CRUD Lista Blanca
    fun agregarWhitelist(numero: String, alias: String?) {
        viewModelScope.launch {
            repository.insertarWhitelist(numero, alias).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al añadir a lista blanca"
            }
        }
    }

    fun eliminarWhitelist(id: Long) {
        viewModelScope.launch {
            repository.eliminarWhitelist(id).onSuccess {
                _mensajeError.value = null
                cargarTodo()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al eliminar de lista blanca"
            }
        }
    }

    // Gestión de Registro
    fun limpiarLogs() {
        viewModelScope.launch {
            repository.limpiarLogs()
            cargarTodo()
        }
    }

    // Simulador
    fun simularLlamada(numero: String): Decision {
        val rules = repository.getRulesForService()
        return MotorFiltrado.decidirDetallado(numero, rules.first, rules.second, rules.third)
    }

    // Importación y Exportación CSV
    fun exportarCsv(): String {
        return CsvParser.exportarCsv(_filtros.value, _bloqueados.value, _whitelist.value)
    }

    fun importarCsv(contenido: String): CsvImportResult {
        val result = CsvParser.importarCsv(contenido, repository)
        cargarTodo()
        return result
    }

    fun limpiarError() {
        _mensajeError.value = null
    }
}
