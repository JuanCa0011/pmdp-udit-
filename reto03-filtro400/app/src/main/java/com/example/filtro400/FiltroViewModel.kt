package com.example.filtro400

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel que gestiona el estado de la UI y conecta la interfaz con el repositorio SQLite
 * utilizando corrutinas de Kotlin y flujos reactivos (StateFlow).
 */
class FiltroViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = FiltroRepository.getInstance(application)

    // Estado interno mutable que almacena la lista de filtros.
    private val _filtros = MutableStateFlow<List<FiltroItem>>(emptyList())
    // Estado público de solo lectura expuesto hacia la UI.
    val filtros: StateFlow<List<FiltroItem>> = _filtros.asStateFlow()

    // Estado para notificar errores a la interfaz de usuario (ej. duplicados o campos vacíos).
    private val _mensajeError = MutableStateFlow<String?>(null)
    val mensajeError: StateFlow<String?> = _mensajeError.asStateFlow()

    init {
        cargarFiltros() // Carga inicial al instanciar el ViewModel.
    }

    /**
     * Carga todos los filtros desde la base de datos de forma asíncrona.
     */
    fun cargarFiltros() {
        viewModelScope.launch {
            _filtros.value = repository.getAllFilters()
        }
    }

    /**
     * Añade un nuevo prefijo a través del repositorio.
     */
    fun agregarFiltro(prefijo: String) {
        viewModelScope.launch {
            val result = repository.insertarFiltro(prefijo)
            result.onSuccess {
                _mensajeError.value = null
                cargarFiltros()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al añadir filtro (posible duplicado)"
            }
        }
    }

    /**
     * Actualiza un prefijo existente.
     */
    fun actualizarFiltro(id: Long, prefijo: String, activo: Boolean) {
        viewModelScope.launch {
            val result = repository.actualizarFiltro(id, prefijo, activo)
            result.onSuccess {
                _mensajeError.value = null
                cargarFiltros()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al actualizar filtro"
            }
        }
    }

    /**
     * Cambia el estado (activo/inactivo) de un filtro mediante su interruptor (Switch).
     */
    fun toggleFiltro(id: Long, activo: Boolean) {
        viewModelScope.launch {
            val result = repository.toggleFiltro(id, activo)
            result.onSuccess {
                _mensajeError.value = null
                cargarFiltros()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al cambiar estado"
            }
        }
    }

    /**
     * Elimina un filtro de la base de datos.
     */
    fun eliminarFiltro(id: Long) {
        viewModelScope.launch {
            val result = repository.eliminarFiltro(id)
            result.onSuccess {
                _mensajeError.value = null
                cargarFiltros()
            }.onFailure { e ->
                _mensajeError.value = e.localizedMessage ?: "Error al eliminar filtro"
            }
        }
    }

    /**
     * Limpia el mensaje de error actual en la UI.
     */
    fun limpiarError() {
        _mensajeError.value = null
    }
}
