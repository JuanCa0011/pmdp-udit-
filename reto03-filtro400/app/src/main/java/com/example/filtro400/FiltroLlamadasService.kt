package com.example.filtro400

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

/**
 * Servicio de interceptación de llamadas ampliado para la Fase 3:
 * emplea la caché optimizada en memoria de reglas y registra las decisiones
 * con números enmascarados en un hilo de fondo tras responder a Android.
 */
class FiltroLlamadasService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val esEntrante = callDetails.callDirection == Call.Details.DIRECTION_INCOMING
        val numero = callDetails.handle?.schemeSpecificPart.orEmpty()

        val repository = FiltroRepository.getInstance(applicationContext)
        val rules = repository.getRulesForService()
        
        // Resolución determinista de conflictos
        val decision = MotorFiltrado.decidirDetallado(numero, rules.first, rules.second, rules.third)
        val bloquear = esEntrante && !decision.permitir

        Log.d("Filtro400", "Llamada de '$numero' -> ${if (bloquear) "BLOQUEADA" else "PERMITIDA"} (${decision.tipoRegla}: ${decision.reglaRef})")

        val respuesta = CallResponse.Builder()
            .setDisallowCall(bloquear)
            .setRejectCall(bloquear)
            .setSkipNotification(bloquear)
            .build()

        respondToCall(callDetails, respuesta)

        // Registrar en segundo plano (privacidad: número enmascarado)
        if (esEntrante && numero.isNotBlank()) {
            val momento = System.currentTimeMillis()
            val numeroEnm = MotorFiltrado.enmascararNumero(numero)
            val estadoDecision = if (bloquear) "BLOQUEADA" else "PERMITIDA"
            Thread {
                repository.registrarLlamada(momento, numeroEnm, estadoDecision, decision.tipoRegla, decision.reglaRef)
            }.start()
        }
    }
}
