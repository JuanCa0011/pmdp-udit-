package com.example.filtro400

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

/**
 * Servicio del sistema Android (CallScreeningService) que intercepta cada llamada entrante
 * en tiempo real antes de que comience a sonar en el dispositivo.
 */
class FiltroLlamadasService : CallScreeningService() {

    // Método llamado automáticamente por Android ante cualquier llamada entrante.
    override fun onScreenCall(callDetails: Call.Details) {
        // Verifica si la llamada es entrante (DIRECTION_INCOMING).
        val esEntrante = callDetails.callDirection == Call.Details.DIRECTION_INCOMING
        // Extrae el número de teléfono del llamante.
        val numero = callDetails.handle?.schemeSpecificPart.orEmpty()

        // Obtiene los filtros activos desde la caché del repositorio SQLite.
        val repository = FiltroRepository.getInstance(applicationContext)
        val filtrosActivos = repository.getActiveFiltersForService()
        
        // Determina si la llamada debe bloquearse utilizando el motor de filtrado.
        val bloquear = esEntrante && MotorFiltrado.decidir(numero, filtrosActivos)

        // Registra el resultado en Logcat para depuración.
        Log.d("Filtro400", "Llamada de '$numero' -> ${if (bloquear) "BLOQUEADA" else "PERMITIDA"} (Filtros activos: $filtrosActivos)")

        // Construye la respuesta para Android indicando si se debe colgar, rechazar o silenciar.
        val respuesta = CallResponse.Builder()
            .setDisallowCall(bloquear)      // Impide que el teléfono empiece a sonar.
            .setRejectCall(bloquear)        // Rechaza la llamada entrante.
            .setSkipNotification(bloquear)  // Oculta la notificación de llamada perdida.
            .build()

        respondToCall(callDetails, respuesta)
    }
}
