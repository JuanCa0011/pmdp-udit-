package com.example.reto1_tarjetapresentacion

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.reto1_tarjetapresentacion.ui.theme.Reto1TarjetaPresentacionTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            // Aplicamos el tema de colores del proyecto a todo lo de dentro[cite: 6]
            Reto1TarjetaPresentacionTheme {
                // Surface = el "lienzo" de fondo que ocupa toda la pantalla[cite: 6]
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    // Aquí llamamos a NUESTRA función, la que dibuja la tarjeta[cite: 6]
                    TarjetaPresentacion()
                }
            }
        }
    }
}

@Composable
fun TarjetaPresentacion() {
    // LocalContext: así un Composable "pide prestado" el contexto de Android[cite: 5]
    // Lo necesitamos para poder abrir el navegador desde el botón.[cite: 5]
    val context = LocalContext.current

    // 1. COLUMN: apila los elementos de arriba a abajo (como un flexbox vertical)[cite: 5]
    Column(
        modifier = Modifier
            .fillMaxSize() // ocupa toda la pantalla[cite: 5]
            .padding(all = 16.dp), // margen para que nada toque los bordes[cite: 5]
        horizontalAlignment = Alignment.CenterHorizontally, // centra en el eje X[cite: 5]
        verticalArrangement = Arrangement.Center // centra en el eje Y[cite: 5]
    ) {
        // 2. IMAGE: la foto de perfil[cite: 5]
        // Requiere un archivo 'foto_perfil' dentro de res/drawable[cite: 5]
        Image(
            painter = painterResource(id = R.drawable.foto_perfil),
            contentDescription = "Foto de perfil de usuario", // para accesibilidad (lectores d[cite: 5]
            modifier = Modifier
                .size(150.dp) // tamaño fijo: 150x150[cite: 5]
                .clip(CircleShape), // la recorta en forma de círculo[cite: 5]
            contentScale = ContentScale.Crop // rellena el círculo sin deformar la imagen[cite: 5]
        )

        // Hueco vacío entre la imagen y el texto[cite: 3, 4]
        Spacer(modifier = Modifier.height(24.dp))

        // 3. TEXT: nombre[cite: 3, 4]
        Text(
            text = "Juan Giménez", // cada alumno pone el suyo[cite: 3, 4]
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold
        )

        // TEXT: rol o profesión[cite: 3, 4]
        Text(
            text = "Desarrollador MERN & Docente DAM", // cada alumno pone el suyo[cite: 3, 4]
            fontSize = 18.sp,
            color = MaterialTheme.colorScheme.secondary // color secundario del tema[cite: 3, 4]
        )

        // Hueco más grande antes del botón[cite: 3, 4]
        Spacer(modifier = Modifier.height(32.dp))

        // 4. BUTTON: enlace a GitHub[cite: 2]
        Button(
            onClick = {
                // 1. Intent ACTION_VIEW: le decimos a Android "quiero VER este recurso"[cite: 2]
                // y el sistema decide qué app usar (normalmente, el navegador)[cite: 2]
                // 2. Uri.parse convierte el texto de la URL en el formato que Android entiende[cite: 2]
                // 3. startActivity lanza esa acción[cite: 2]
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/JuanCa0011"))
                context.startActivity(intent)
            },
            modifier = Modifier.fillMaxWidth(fraction = 0.8f) // ocupa el 80% del ancho de pantalla[cite: 2]
        ) {
            Text(text = "Mi Perfil de GitHub")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun TarjetaPreview() {
    Reto1TarjetaPresentacionTheme {
        TarjetaPresentacion()
    }
}