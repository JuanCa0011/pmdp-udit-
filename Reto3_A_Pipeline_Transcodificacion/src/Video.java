/**
 * Un tráiler del lote: nombre del fichero y duración simulada de su transcodificación.
 * Es un record porque solo transporta datos inmutables.
 */
public record Video(String nombre, long duracionMs) {
}
