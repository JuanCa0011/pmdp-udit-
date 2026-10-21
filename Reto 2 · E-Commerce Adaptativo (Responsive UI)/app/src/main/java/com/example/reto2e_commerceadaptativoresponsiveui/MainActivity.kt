package com.example.reto2e_commerceadaptativoresponsiveui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow.Companion.Ellipsis
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Celeste = Color(0xFF58AEEA)
private val AzulOscuro = Color(0xFF17466A)
private val FondoTienda = Color(0xFFEAF7FF)
private val BordeTarjeta = Color(0xFFB9DFF5)
private val FondoImagen = Color(0xFFF4FBFF)

/**
 * Actividad Principal (MainActivity)
 * Punto de entrada de la aplicación Android. Configura el tema Material3
 * y establece el contenido raíz con Jetpack Compose.
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Celeste
                ) {
                    PantallaPrincipal()
                }
            }
        }
    }
}

/**
 * Modelo de Datos: Producto
 * Define la estructura de cada artículo en la tienda (nombre, precio y referencia de imagen).
 */
data class Producto(
    val nombre: String,
    val precio: String,
    val descripcion: String,
    val imanResId: Int
)

val catalogoRaquetas = listOf(
    Producto(
        "Raqueta Dunlop FX 500 LS",
        "159,95 €",
        "Ligera y manejable, ideal para ganar velocidad en cada golpe.",
        R.drawable.dunlopfx500ls
    ),
    Producto(
        "Raqueta Babolat Pure Aero 98",
        "279,95 €",
        "Potencia y efecto para jugadores que buscan dominar desde el fondo.",
        R.drawable.babolatpureaero98
    ),
    Producto(
        "Raqueta Head Speed MP 2026",
        "279,95 €",
        "Gran equilibrio entre control, estabilidad y velocidad.",
        R.drawable.headspeedmp2026
    ),
    Producto(
        "Raqueta Wilson Blade V10",
        "269,95 €",
        "Sensación precisa y excelente control para un juego agresivo.",
        R.drawable.wilsonbladev10
    ),
    Producto(
        "Raqueta Wilson Blade 98 Pro V10",
        "299,95 €",
        "Marco de competición para golpes firmes y máxima precisión.",
        R.drawable.wilsonblade_98prov10
    ),
    Producto(
        "Raqueta Wilson Defyer 98 Pro V1",
        "219,95 €",
        "Control y estabilidad en una raqueta versátil de 98 pulgadas.",
        R.drawable.wilsondefyer98prov1
    ),
    Producto(
        "Raqueta Wilson Pro Staff 97 Classic",
        "299,95 €",
        "Diseño clásico con tacto excepcional para jugadores avanzados.",
        R.drawable.wilsonprostaff97classic
    ),
    Producto(
        "Raqueta Wilson Pro Staff X V14",
        "249,95 €",
        "Punto dulce amplio y precisión para un juego completo.",
        R.drawable.wilsonprostaffxv14
    )
)

@Composable
fun CatalogoRaquetas(
    productos: List<Producto>,
    cantidadEnCesta: Int,
    onAnadirALaCesta: () -> Unit
) {
    var busqueda by remember { mutableStateOf("") }
    val productosFiltrados = productos.filter {
        it.nombre.contains(busqueda, ignoreCase = true)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp)
                .background(Celeste),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Mi Tienda",
                color = Color.White,
                fontSize = 18.sp,
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = "Cesta ($cantidadEnCesta)",
                modifier = Modifier
                    .align(Alignment.CenterEnd)
                    .padding(end = 16.dp),
                color = Color.White,
                fontSize = 13.sp
            )
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .background(FondoTienda)
        ) {
            OutlinedTextField(
                value = busqueda,
                onValueChange = { busqueda = it },
                label = { Text("Buscar raquetas") },
                singleLine = true,
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 12.dp, vertical = 8.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = Celeste,
                    unfocusedBorderColor = BordeTarjeta,
                    focusedTextColor = AzulOscuro,
                    unfocusedTextColor = AzulOscuro,
                    focusedLabelColor = Celeste,
                    unfocusedLabelColor = Celeste,
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White,
                    cursorColor = Celeste
                )
            )

            Text(
                text = if (productosFiltrados.isEmpty()) {
                    "No se encontraron raquetas."
                } else {
                    "Raquetas de tenis  ·  ${productosFiltrados.size} productos"
                },
                modifier = Modifier.padding(start = 14.dp, top = 2.dp, bottom = 2.dp),
                color = AzulOscuro,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium
            )

            if (productosFiltrados.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Prueba con otra búsqueda.",
                        color = AzulOscuro,
                        textAlign = TextAlign.Center
                    )
                }
            } else {
                BoxWithConstraints(modifier = Modifier.weight(1f)) {
                    val minCellSize = if (maxWidth >= 720.dp) {
                        maxWidth / 4 - 16.dp
                    } else {
                        160.dp
                    }

                    LazyVerticalGrid(
                        columns = GridCells.Adaptive(minSize = minCellSize),
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(8.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(productosFiltrados) { producto ->
                            TarjetaProducto(
                                producto = producto,
                                onAnadirALaCesta = onAnadirALaCesta
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun TarjetaProducto(
    producto: Producto,
    onAnadirALaCesta: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(116.dp)
                    .background(FondoImagen)
                    .border(1.dp, BordeTarjeta, RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter = painterResource(id = producto.imanResId),
                    contentDescription = producto.nombre,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(6.dp),
                    contentScale = ContentScale.Fit
                )
            }

            Column(
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 7.dp)
            ) {
                Text(
                    text = producto.nombre,
                    fontSize = 13.sp,
                    lineHeight = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = AzulOscuro,
                    minLines = 2,
                    maxLines = 2,
                    overflow = Ellipsis
                )
                Text(
                    text = producto.precio,
                    fontSize = 13.sp,
                    lineHeight = 17.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AzulOscuro,
                    modifier = Modifier.padding(top = 2.dp)
                )
                Text(
                    text = producto.descripcion,
                    fontSize = 11.sp,
                    lineHeight = 14.sp,
                    color = Color(0xFF63738A),
                    modifier = Modifier.padding(top = 3.dp),
                    minLines = 1,
                    maxLines = 1,
                    overflow = Ellipsis
                )
                Button(
                    onClick = onAnadirALaCesta,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 5.dp)
                        .height(34.dp),
                    shape = RoundedCornerShape(9.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Celeste,
                        contentColor = Color.White
                    ),
                    contentPadding = PaddingValues(horizontal = 4.dp, vertical = 0.dp)
                ) {
                    Text(
                        text = "Añadir",
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 12.sp,
                        maxLines = 1
                    )
                }
            }
        }
    }
}

@Composable
fun PantallaPrincipal() {
    var cantidadEnCesta by remember { mutableStateOf(0) }

    CatalogoRaquetas(
        productos = catalogoRaquetas,
        cantidadEnCesta = cantidadEnCesta,
        onAnadirALaCesta = { cantidadEnCesta++ }
    )
}
