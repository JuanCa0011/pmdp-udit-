/**
 * Trabajo de transcodificación de UN vídeo.
 * Implementa Runnable: describe QUÉ se hace, no CÓMO se ejecuta.
 * - Si se llama a run() directamente, se ejecuta en el hilo actual (modo secuencial).
 * - Si se envuelve en un Thread y se llama a start(), se ejecuta en un hilo nuevo (modo concurrente).
 */
public class TareaTranscodificacion implements Runnable {

    private final Video video;

    public TareaTranscodificacion(Video video) {
        this.video = video;
    }

    @Override
    public void run() {
        String hilo = Thread.currentThread().getName();
        System.out.printf("[%s] INICIO      %-15s (%d ms)%n", hilo, video.nombre(), video.duracionMs());
        try {
            // Simula el trabajo pesado. Mientras duerme, el hilo está en TIMED_WAITING.
            Thread.sleep(video.duracionMs());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.out.printf("[%s] INTERRUMPIDO %s%n", hilo, video.nombre());
            return;
        }
        System.out.printf("[%s] COMPLETADO  %-15s%n", hilo, video.nombre());
    }
}
