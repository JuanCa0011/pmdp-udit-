package com.example.filtro400

import android.app.role.RoleManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel

/**
 * Actividad principal de la aplicación. Muestra la interfaz gráfica construida en Jetpack Compose,
 * gestiona la solicitud del rol de filtrado de llamadas del sistema, la lista CRUD de prefijos
 * y el probador interactivo de números.
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    PantallaFiltroPrincipal()
                }
            }
        }
    }
}

@Composable
fun PantallaFiltroPrincipal(viewModel: FiltroViewModel = viewModel()) {
    val context = LocalContext.current
    val roleManager = remember { context.getSystemService(RoleManager::class.java) }

    // Estado reactivo que comprueba si la app posee actualmente el rol de Call Screening.
    var filtroActivo by remember {
        mutableStateOf(roleManager?.isRoleHeld(RoleManager.ROLE_CALL_SCREENING) == true)
    }

    // Lanzador para solicitar al usuario el rol de filtrado de llamadas del sistema.
    val lanzador = rememberLauncherForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) {
        filtroActivo = roleManager?.isRoleHeld(RoleManager.ROLE_CALL_SCREENING) == true
    }

    // Recoge la lista de filtros y errores desde el ViewModel de manera reactiva.
    val filtros by viewModel.filtros.collectAsState()
    val mensajeError by viewModel.mensajeError.collectAsState()

    // Estados locales para los campos de texto e interacciones de la UI.
    var nuevoPrefijo by remember { mutableStateOf("") }
    var numeroPrueba by remember { mutableStateOf("") }
    var resultadoPrueba by remember { mutableStateOf("") }

    // Estados para el diálogo de edición de un prefijo existente.
    var filtroAEditar by remember { mutableStateOf<FiltroItem?>(null) }
    var textoEditado by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Cabecera de la app y estado del rol del sistema
        Text("Filtro 400 - Gestión", fontSize = 26.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = if (filtroActivo) "✅ Rol de Filtrado ACTIVO" else "⚠️ Rol inactivo (necesario para bloquear)",
            fontSize = 14.sp
        )
        if (!filtroActivo) {
            Spacer(modifier = Modifier.height(8.dp))
            Button(onClick = {
                roleManager?.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)?.let {
                    lanzador.launch(it)
                }
            }) {
                Text("Activar rol de llamadas")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Banner de notificación de errores (si ocurre alguno)
        if (mensajeError != null) {
            Card(
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(mensajeError ?: "", color = MaterialTheme.colorScheme.onErrorContainer, modifier = Modifier.weight(1f))
                    TextButton(onClick = { viewModel.limpiarError() }) {
                        Text("OK")
                    }
                }
            }
            Spacer(modifier = Modifier.height(12.dp))
        }

        // Sección para añadir nuevos prefijos de bloqueo
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = nuevoPrefijo,
                onValueChange = { nuevoPrefijo = it },
                label = { Text("Nuevo prefijo (ej. 400)") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true,
                modifier = Modifier.weight(1f)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Button(onClick = {
                if (nuevoPrefijo.isNotBlank()) {
                    viewModel.agregarFiltro(nuevoPrefijo)
                    nuevoPrefijo = ""
                }
            }) {
                Text("Añadir")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text("Prefijos Configurados", fontWeight = FontWeight.Bold, fontSize = 16.sp)
        Spacer(modifier = Modifier.height(8.dp))

        // Lista de prefijos con LazyColumn (eficiente para listas y scroll)
        Box(modifier = Modifier.weight(1f)) {
            if (filtros.isEmpty()) {
                Text("No hay filtros configurados.", modifier = Modifier.align(Alignment.Center))
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(filtros, key = { it.id }) { filtro ->
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Prefijo: ${filtro.prefijo}", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                                    Text(
                                        text = if (filtro.activo) "Activo" else "Inactivo",
                                        fontSize = 12.sp,
                                        color = if (filtro.activo) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline
                                    )
                                }

                                // Interruptor (Switch) para activar o desactivar cada filtro individualmente
                                Switch(
                                    checked = filtro.activo,
                                    onCheckedChange = { isChecked ->
                                        viewModel.toggleFiltro(filtro.id, isChecked)
                                    }
                                )

                                // Botón para abrir diálogo de edición
                                TextButton(onClick = {
                                    filtroAEditar = filtro
                                    textoEditado = filtro.prefijo
                                }) {
                                    Text("Editar")
                                }

                                // Botón para eliminar el filtro de la base de datos
                                TextButton(onClick = {
                                    viewModel.eliminarFiltro(filtro.id)
                                }) {
                                    Text("Eliminar", color = MaterialTheme.colorScheme.error)
                                }
                            }
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Probador interactivo de números usando el motor y la base de datos real
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text("Probador de Números", fontWeight = FontWeight.Bold)
                Spacer(modifier = Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    OutlinedTextField(
                        value = numeroPrueba,
                        onValueChange = { numeroPrueba = it },
                        label = { Text("Teléfono a probar") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Button(onClick = {
                        val filtrosActivosList = filtros.filter { it.activo }.map { it.prefijo }
                        val bloquear = MotorFiltrado.decidir(numeroPrueba, filtrosActivosList)
                        resultadoPrueba = if (bloquear) "🚫 Se BLOQUEARÍA" else "✅ Pasaría"
                    }) {
                        Text("Probar")
                    }
                }
                if (resultadoPrueba.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(resultadoPrueba, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }

    // Diálogo emergente para editar un prefijo existente
    if (filtroAEditar != null) {
        AlertDialog(
            onDismissRequest = { filtroAEditar = null },
            title = { Text("Editar Prefijo") },
            text = {
                OutlinedTextField(
                    value = textoEditado,
                    onValueChange = { textoEditado = it },
                    label = { Text("Prefijo") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    filtroAEditar?.let { item ->
                        viewModel.actualizarFiltro(item.id, textoEditado, item.activo)
                    }
                    filtroAEditar = null
                }) {
                    Text("Guardar")
                }
            },
            dismissButton = {
                TextButton(onClick = { filtroAEditar = null }) {
                    Text("Cancelar")
                }
            }
        )
    }
}
