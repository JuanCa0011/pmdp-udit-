package com.example.filtro400

import android.app.role.RoleManager
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.filtro400.ia.*
import com.example.filtro400.ui.theme.Filtro400Theme
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Filtro400Theme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainScreen()
                }
            }
        }
    }
}

@Composable
fun MainScreen(viewModel: FiltroViewModel = viewModel()) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("Prefijos", "Bloqueados", "Lista Blanca", "Registro", "Estadísticas", "CSV")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .padding(16.dp)
    ) {
        // Top Bar
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("FILTRO DE LLAMADAS", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
            RoleStatusBadge()
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Navigation Tabs
        ScrollableTabRow(
            selectedTabIndex = selectedTab,
            edgePadding = 0.dp,
            containerColor = MaterialTheme.colorScheme.surface,
            contentColor = MaterialTheme.colorScheme.primary,
            modifier = Modifier.clip(RoundedCornerShape(12.dp))
        ) {
            tabs.forEachIndexed { index, title ->
                Tab(
                    selected = selectedTab == index,
                    onClick = { selectedTab = index },
                    text = { Text(title, fontSize = 12.sp, color = if (selectedTab == index) Color.White else Color.LightGray) }
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Content Area (Management Screens)
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            when (selectedTab) {
                0 -> PantallaPrefijos(viewModel)
                1 -> PantallaBloqueados(viewModel)
                2 -> PantallaListaBlanca(viewModel)
                3 -> PantallaRegistro(viewModel)
                4 -> PantallaEstadisticas(viewModel)
                5 -> PantallaCsv(viewModel)
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Bottom AI Assistant Voice Card (Differentiated by Light/Emerald Green and constrained height)
        AsistenteIaCard(viewModel)
    }
}

@Composable
fun RoleStatusBadge() {
    val context = LocalContext.current
    val roleManager = remember { context.getSystemService(RoleManager::class.java) }
    var filtroActivo by remember { mutableStateOf(roleManager?.isRoleHeld(RoleManager.ROLE_CALL_SCREENING) == true) }

    val lanzador = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) {
        filtroActivo = roleManager?.isRoleHeld(RoleManager.ROLE_CALL_SCREENING) == true
    }

    if (!filtroActivo) {
        Button(
            onClick = {
                roleManager?.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)?.let { lanzador.launch(it) }
            },
            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
        ) {
            Text("Activar Rol", fontSize = 11.sp, color = Color.White)
        }
    } else {
        Badge(containerColor = Color(0xFF38BDF8)) {
            Text("PRO", modifier = Modifier.padding(4.dp), color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 10.sp)
        }
    }
}

// 1. PANTALLA PREFIJOS (con Prioridad)
@Composable
fun PantallaPrefijos(viewModel: FiltroViewModel) {
    val filtros by viewModel.filtros.collectAsState()
    var prefijo by remember { mutableStateOf("") }
    var prioridad by remember { mutableStateOf("0") }

    var filtroAEditar by remember { mutableStateOf<FiltroItem?>(null) }
    var textoEditado by remember { mutableStateOf("") }
    var prioridadEditada by remember { mutableStateOf("0") }

    Column(modifier = Modifier.fillMaxSize()) {
        Text("Gestión de Prefijos (Prioritarios)", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
        Spacer(modifier = Modifier.height(8.dp))

        Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)) {
            Column(modifier = Modifier.padding(12.dp)) {
                OutlinedTextField(
                    value = prefijo,
                    onValueChange = { prefijo = it },
                    label = { Text("Prefijo (ej. 400)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = prioridad,
                    onValueChange = { prioridad = it },
                    label = { Text("Prioridad (mayor número = más prioridad)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(8.dp))
                Button(
                    onClick = {
                        if (prefijo.isNotBlank()) {
                            val prio = prioridad.toIntOrNull() ?: 0
                            viewModel.agregarFiltro(prefijo, prio)
                            prefijo = ""
                            prioridad = "0"
                        }
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Añadir Prefijo")
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(filtros, key = { it.id }) { filtro ->
                Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("Prefijo: ${filtro.prefijo}", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
                            Text("Prioridad: ${filtro.prioridad}", fontSize = 12.sp, color = Color(0xFF38BDF8))
                        }
                        Switch(
                            checked = filtro.activo,
                            onCheckedChange = { viewModel.toggleFiltro(filtro.id, it) }
                        )
                        TextButton(onClick = {
                            filtroAEditar = filtro
                            textoEditado = filtro.prefijo
                            prioridadEditada = filtro.prioridad.toString()
                        }) { Text("Editar", color = Color(0xFF38BDF8)) }
                        TextButton(onClick = { viewModel.eliminarFiltro(filtro.id) }) {
                            Text("Eliminar", color = MaterialTheme.colorScheme.error)
                        }
                    }
                }
            }
        }
    }

    if (filtroAEditar != null) {
        AlertDialog(
            onDismissRequest = { filtroAEditar = null },
            title = { Text("Editar Prefijo", color = Color.White) },
            text = {
                Column {
                    OutlinedTextField(value = textoEditado, onValueChange = { textoEditado = it }, label = { Text("Prefijo") })
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(value = prioridadEditada, onValueChange = { prioridadEditada = it }, label = { Text("Prioridad") })
                }
            },
            confirmButton = {
                TextButton(onClick = {
                    filtroAEditar?.let {
                        viewModel.actualizarFiltro(it.id, textoEditado, it.activo, prioridadEditada.toIntOrNull() ?: 0)
                    }
                    filtroAEditar = null
                }) { Text("Guardar") }
            },
            dismissButton = { TextButton(onClick = { filtroAEditar = null }) { Text("Cancelar") } }
        )
    }
}

// 2. PANTALLA NÚMEROS BLOQUEADOS
@Composable
fun PantallaBloqueados(viewModel: FiltroViewModel) {
    val bloqueados by viewModel.bloqueados.collectAsState()
    var numero by remember { mutableStateOf("") }
    var alias by remember { mutableStateOf("") }

    Column(modifier = Modifier.fillMaxSize()) {
        Text("Números Bloqueados (Exactos)", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
        Spacer(modifier = Modifier.height(8.dp))

        Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)) {
            Column(modifier = Modifier.padding(12.dp)) {
                OutlinedTextField(
                    value = numero,
                    onValueChange = { numero = it },
                    label = { Text("Número (ej. 600123456)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = alias,
                    onValueChange = { alias = it },
                    label = { Text("Alias / Descripción (opcional)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(8.dp))
                Button(onClick = {
                    if (numero.isNotBlank()) {
                        viewModel.agregarBloqueado(numero, alias.ifBlank { null })
                        numero = ""
                        alias = ""
                    }
                }, modifier = Modifier.fillMaxWidth()) {
                    Text("Bloquear Número")
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(bloqueados, key = { it.id }) { item ->
                Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(item.numeroNormalizado, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
                            if (!item.alias.isNullOrBlank()) Text("Alias: ${item.alias}", fontSize = 12.sp, color = Color.LightGray)
                        }
                        Switch(checked = item.activo, onCheckedChange = { viewModel.toggleBloqueado(item.id, it) })
                        TextButton(onClick = { viewModel.eliminarBloqueado(item.id) }) {
                            Text("Eliminar", color = MaterialTheme.colorScheme.error)
                        }
                    }
                }
            }
        }
    }
}

// 3. PANTALLA LISTA BLANCA
@Composable
fun PantallaListaBlanca(viewModel: FiltroViewModel) {
    val whitelist by viewModel.whitelist.collectAsState()
    var numero by remember { mutableStateOf("") }
    var alias by remember { mutableStateOf("") }

    Column(modifier = Modifier.fillMaxSize()) {
        Text("Lista Blanca (Exentos de Bloqueo)", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
        Spacer(modifier = Modifier.height(8.dp))

        Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)) {
            Column(modifier = Modifier.padding(12.dp)) {
                OutlinedTextField(
                    value = numero,
                    onValueChange = { numero = it },
                    label = { Text("Número exento") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = alias,
                    onValueChange = { alias = it },
                    label = { Text("Alias (opcional)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(8.dp))
                Button(onClick = {
                    if (numero.isNotBlank()) {
                        viewModel.agregarWhitelist(numero, alias.ifBlank { null })
                        numero = ""
                        alias = ""
                    }
                }, modifier = Modifier.fillMaxWidth()) {
                    Text("Añadir a Lista Blanca")
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(whitelist, key = { it.id }) { item ->
                Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(item.numeroNormalizado, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
                            if (!item.alias.isNullOrBlank()) Text("Alias: ${item.alias}", fontSize = 12.sp, color = Color.LightGray)
                        }
                        TextButton(onClick = { viewModel.eliminarWhitelist(item.id) }) {
                            Text("Eliminar", color = MaterialTheme.colorScheme.error)
                        }
                    }
                }
            }
        }
    }
}

// 4. PANTALLA REGISTRO DE ACTIVIDAD
@Composable
fun PantallaRegistro(viewModel: FiltroViewModel) {
    val logs by viewModel.logs.collectAsState()
    val dateFormat = remember { SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.getDefault()) }

    Column(modifier = Modifier.fillMaxSize()) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Text("Registro de Actividad", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
            OutlinedButton(onClick = { viewModel.limpiarLogs() }) {
                Text("Vaciar Registro", color = MaterialTheme.colorScheme.error)
            }
        }
        Spacer(modifier = Modifier.height(8.dp))

        LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(logs, key = { it.id }) { log ->
                Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text(log.numeroEnmascarado, fontWeight = FontWeight.Bold, fontSize = 15.sp, color = Color.White)
                            Text(
                                text = log.decision,
                                color = if (log.decision == "BLOQUEADA") MaterialTheme.colorScheme.error else Color(0xFF38BDF8),
                                fontWeight = FontWeight.Bold,
                                fontSize = 13.sp
                            )
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                        Text("Regla: ${log.tipoRegla} (${log.reglaRef})", fontSize = 12.sp, color = Color.LightGray)
                        Text(dateFormat.format(Date(log.momento)), fontSize = 11.sp, color = MaterialTheme.colorScheme.outline)
                    }
                }
            }
        }
    }
}

// 5. PANTALLA ESTADÍSTICAS
@Composable
fun PantallaEstadisticas(viewModel: FiltroViewModel) {
    val stats by viewModel.estadisticas.collectAsState()
    val totalBloq = stats["totalBloqueadas"] as? Int ?: 0
    val totalPerm = stats["totalPermitidas"] as? Int ?: 0
    val porRegla = stats["porRegla"] as? Map<*, *> ?: emptyMap<Any, Any>()

    Column(modifier = Modifier.fillMaxSize()) {
        Text("Estadísticas de Filtrado", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
        Spacer(modifier = Modifier.height(12.dp))

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Card(modifier = Modifier.weight(1f), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer)) {
                Column(modifier = Modifier.padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("Bloqueadas", fontSize = 12.sp, color = MaterialTheme.colorScheme.onErrorContainer)
                    Text("$totalBloq", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onErrorContainer)
                }
            }
            Card(modifier = Modifier.weight(1f), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.tertiaryContainer)) {
                Column(modifier = Modifier.padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("Permitidas", fontSize = 12.sp, color = MaterialTheme.colorScheme.onTertiaryContainer)
                    Text("$totalPerm", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onTertiaryContainer)
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))
        Text("Bloqueos por Regla (Top)", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = Color.White)
        Spacer(modifier = Modifier.height(8.dp))

        LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            items(porRegla.entries.toList()) { entry ->
                Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)) {
                    Row(modifier = Modifier.padding(12.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(entry.key.toString(), fontSize = 14.sp, color = Color.White)
                        Text("${entry.value} bloqueos", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = Color(0xFF38BDF8))
                    }
                }
            }
        }
    }
}

// 7. PANTALLA IMPORT / EXPORT CSV
@Composable
fun PantallaCsv(viewModel: FiltroViewModel) {
    val context = LocalContext.current
    var mensajeResultado by remember { mutableStateOf("") }

    val exportLauncher = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("text/csv")) { uri: Uri? ->
        uri?.let {
            try {
                val csvContent = viewModel.exportarCsv()
                context.contentResolver.openOutputStream(it)?.use { output ->
                    output.write(csvContent.toByteArray())
                }
                mensajeResultado = "✅ Exportado correctamente."
            } catch (e: Exception) {
                mensajeResultado = "❌ Error al exportar: ${e.localizedMessage}"
            }
        }
    }

    val importLauncher = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri: Uri? ->
        uri?.let {
            try {
                val content = context.contentResolver.openInputStream(it)?.bufferedReader().use { reader -> reader?.readText() }
                if (content != null) {
                    val res = viewModel.importarCsv(content)
                    mensajeResultado = "📥 Importados: ${res.importados}, Rechazados: ${res.rechazados}"
                }
            } catch (e: Exception) {
                mensajeResultado = "❌ Error al importar: ${e.localizedMessage}"
            }
        }
    }

    Column(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
        Text("Importación y Exportación CSV", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = Color.White)
        Spacer(modifier = Modifier.height(24.dp))

        Button(onClick = { exportLauncher.launch("filtros_config.csv") }, modifier = Modifier.fillMaxWidth(0.8f)) {
            Text("Exportar a CSV")
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(onClick = { importLauncher.launch(arrayOf("text/csv", "text/plain", "*/*")) }, modifier = Modifier.fillMaxWidth(0.8f)) {
            Text("Importar desde CSV")
        }

        if (mensajeResultado.isNotEmpty()) {
            Spacer(modifier = Modifier.height(24.dp))
            Text(mensajeResultado, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = Color.White)
        }
    }
}

// ASISTENTE DE VOZ CON IA (Con botón de retroceso para cambiar entre modo Voz y Chat)
@Composable
fun AsistenteIaCard(viewModel: FiltroViewModel) {
    val scope = rememberCoroutineScope()
    val voz = rememberVoz()
    val chat = remember { mutableStateListOf<Msg>() }
    var expandido by remember { mutableStateOf(false) }
    var modo by remember { mutableStateOf<String?>(null) } // "voz" o "chat"
    var entrada by remember { mutableStateOf("") }
    var pensando by remember { mutableStateOf(false) }
    val logs by viewModel.logs.collectAsState()

    fun enviar(texto: String, esVoz: Boolean) {
        if (texto.isBlank() || pensando) return
        chat += Msg("user", texto)
        pensando = true
        scope.launch {
            try {
                val textoRegistro = if (logs.isEmpty()) "No hay llamadas registradas." else logs.joinToString("\n") {
                    "${it.numeroEnmascarado} · ${it.decision} · Regla: ${it.tipoRegla}"
                }
                val prompt = BaseConocimiento.promptDueno(textoRegistro)
                val r = GroqClient.responder(chat.toList(), prompt)
                chat += Msg("assistant", r)
                if (esVoz) {
                    voz.hablar(r)
                }
            } catch (e: Exception) {
                chat += Msg("assistant", "⚠️ Error con Groq: ${e.message?.take(100)}")
            }
            pensando = false
        }
    }
    val escuchar = rememberEscuchar(voz) { enviar(it, true) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF064E3B)) // Verde esmeralda claro distintivo
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("🤖", fontSize = 22.sp)
                    Column {
                        Text("Asistente de voz con IA", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = Color.White)
                        Text(
                            when (modo) {
                                "voz" -> "Modo Voz Activo 🎙️"
                                "chat" -> "Modo Chat Activo 💬"
                                else -> "Selecciona tu modo de asistente"
                            },
                            fontSize = 11.sp,
                            color = Color(0xFFA7F3D0)
                        )
                    }
                }
                TextButton(onClick = { 
                    expandido = !expandido
                    if (!expandido) modo = null
                }) {
                    Text(if (expandido) "Ocultar 🔼" else "Abrir 🤖", color = Color(0xFF34D399), fontSize = 12.sp)
                }
            }

            if (expandido) {
                Spacer(modifier = Modifier.height(10.dp))

                if (modo == null) {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                        Text("¿Cómo deseas interactuar con tu asistente?", fontSize = 13.sp, color = Color.White)
                        
                        Button(
                            onClick = { modo = "voz"; voz.sonido = true },
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF059669))
                        ) {
                            Text("🎙️ Asistente de Voz (Hablar y escuchar)", fontSize = 13.sp, color = Color.White)
                        }

                        Button(
                            onClick = { modo = "chat"; voz.sonido = false },
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF047857))
                        ) {
                            Text("💬 Asistente de Chat (Escribir)", fontSize = 13.sp, color = Color.White)
                        }
                    }
                } else {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        TextButton(onClick = { modo = null; voz.callar() }) {
                            Text("🔙 Volver a selección", color = Color(0xFF34D399), fontSize = 12.sp)
                        }
                        Text(
                            if (modo == "voz") "🎙️ Modo Voz" else "💬 Modo Chat",
                            fontSize = 12.sp,
                            color = Color.LightGray
                        )
                    }
                    Spacer(modifier = Modifier.height(4.dp))

                    if (chat.isEmpty()) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Button(
                                onClick = { enviar("¿Qué llamadas he recibido?", modo == "voz") },
                                modifier = Modifier.weight(1f),
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF059669))
                            ) {
                                Text("📋 Resumen", fontSize = 11.sp, color = Color.White)
                            }
                            Button(
                                onClick = { enviar("Hola, ¿cómo estás?", modo == "voz") },
                                modifier = Modifier.weight(1f),
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF047857))
                            ) {
                                Text("👋 Saludar", fontSize = 11.sp, color = Color.White)
                            }
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                    }

                    Box(
                        modifier = Modifier
                            .heightIn(max = 150.dp)
                            .fillMaxWidth()
                    ) {
                        LazyColumn(
                            modifier = Modifier.fillMaxSize(),
                            verticalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            items(chat) { BurbujaMsg(it) }
                            if (pensando) item { Text("🤖 Analizando llamadas...", fontSize = 12.sp, color = Color(0xFFA7F3D0)) }
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    if (modo == "voz") {
                        Button(
                            onClick = escuchar,
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = if (voz.escuchando) MaterialTheme.colorScheme.error else Color(0xFF059669))
                        ) {
                            Text(if (voz.escuchando) "🎙️ Escuchando... (Habla ahora)" else "🎙️ Toca para hablar con el asistente", fontSize = 13.sp, color = Color.White)
                        }
                    } else {
                        BarraEntrada(
                            texto = entrada,
                            onTexto = { entrada = it },
                            onEnviar = { enviar(entrada, false); entrada = "" },
                            onMic = { /* no op */ },
                            escuchando = false,
                            placeholder = "Escribe un mensaje..."
                        )
                    }
                }
            }
        }
    }
}
