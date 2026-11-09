package com.example.filtro400.ia

import com.example.filtro400.BuildConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

data class Msg(val role: String, val text: String)

/**
 * Cliente de Groq. La API Key NO está en el código: se lee de BuildConfig,
 * que Gradle genera a partir de GROQ_API_KEY en local.properties (ignorado por git).
 */
object GroqClient {
    var apiKey: String = BuildConfig.GROQ_API_KEY

    private const val URL_API = "https://api.groq.com/openai/v1/chat/completions"
    private const val MODELO = "llama-3.3-70b-versatile"

    suspend fun responder(
        historial: List<Msg>,
        system: String = BaseConocimiento.PROMPT_LLAMANTE
    ): String = withContext(Dispatchers.IO) {
        if (apiKey.isBlank()) {
            throw IllegalArgumentException("Falta la API Key de Groq.")
        }
        val mensajes = JSONArray().put(JSONObject().put("role", "system").put("content", system))
        historial.forEach { mensajes.put(JSONObject().put("role", it.role).put("content", it.text)) }
        val cuerpo = JSONObject()
            .put("model", MODELO)
            .put("messages", mensajes)
            .put("temperature", 0.4)
            .put("max_tokens", 800)

        val con = (URL(URL_API).openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            connectTimeout = 10_000
            readTimeout = 20_000
            doOutput = true
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty("Authorization", "Bearer $apiKey")
        }
        con.outputStream.use { it.write(cuerpo.toString().toByteArray()) }
        val ok = con.responseCode in 200..299
        val texto = (if (ok) con.inputStream else con.errorStream).bufferedReader().readText()
        if (!ok) error("Groq ${con.responseCode}: $texto")
        JSONObject(texto).getJSONArray("choices").getJSONObject(0)
            .getJSONObject("message").getString("content").trim()
    }

    suspend fun resumir(historial: List<Msg>): String {
        val transcripcion = historial.joinToString("\n") {
            (if (it.role == "user") "Llamante: " else "Asistente: ") + it.text
        }
        return responder(
            listOf(Msg("user", "Resume en 2 líneas: quién llamó, motivo y si es urgente.\n\n$transcripcion")),
            system = "Resumes llamadas telefónicas en español, de forma breve y clara."
        )
    }
}
