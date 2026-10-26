package com.example.filtro400.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val BlackBlueGreenColorScheme = darkColorScheme(
    primary = PrimaryBlue,
    onPrimary = TextWhite,
    primaryContainer = PrimaryBlueVariant,
    onPrimaryContainer = TextWhite,
    secondary = SecondaryGreen,
    onSecondary = TextWhite,
    tertiary = AccentGreen,
    background = BlackBackground,
    onBackground = TextWhite,
    surface = SurfaceDark,
    onSurface = TextWhite,
    surfaceVariant = SurfaceCard,
    onSurfaceVariant = TextGray,
    error = ErrorRed,
    onError = TextWhite
)

@Composable
fun Filtro400Theme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = BlackBlueGreenColorScheme,
        typography = Typography,
        content = content
    )
}
