package com.example.filtro400.ia

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun BurbujaMsg(m: Msg) {
    val yo = m.role == "user"
    Row(Modifier.fillMaxWidth(), horizontalArrangement = if (yo) Arrangement.End else Arrangement.Start) {
        Surface(
            color = if (yo) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceVariant,
            shape = RoundedCornerShape(
                topStart = 18.dp, topEnd = 18.dp,
                bottomStart = if (yo) 18.dp else 4.dp, bottomEnd = if (yo) 4.dp else 18.dp
            ),
            modifier = Modifier.widthIn(max = 300.dp)
        ) {
            Text(m.text, Modifier.padding(horizontal = 14.dp, vertical = 10.dp), color = MaterialTheme.colorScheme.onSurface)
        }
    }
}

@Composable
fun BarraEntrada(
    texto: String, onTexto: (String) -> Unit, onEnviar: () -> Unit,
    onMic: () -> Unit, escuchando: Boolean, placeholder: String
) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        OutlinedTextField(
            value = texto, onValueChange = onTexto, modifier = Modifier.weight(1f),
            placeholder = { Text(placeholder) }, singleLine = true, shape = RoundedCornerShape(24.dp)
        )
        FilledIconButton(onClick = onMic) { Text(if (escuchando) "…" else "🎤") }
        FilledIconButton(onClick = onEnviar) { Text("➤") }
    }
}
