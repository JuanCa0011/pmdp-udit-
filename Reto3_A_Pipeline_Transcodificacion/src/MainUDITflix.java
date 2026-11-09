/**
 * Motor de transcodificación de UDITflix.
 * 1) Modo secuencial real: las 4 tareas una tras otra (run() en el hilo main).
 * 2) Modo concurrente: un hilo por vídeo (start() + join()) vigilado por el Espía de Estados.
 * 3) Resumen: tiempos teóricos, tiempos reales y ahorro.
 */
public class MainUDITflix {

    // RT1: el lote vive en una estructura de datos, no repetido a mano en el código.
    private static final Video[] LOTE = {
            new Video("intro.mp4", 1500),
            new Video("teaser.mp4", 2500),
            new Video("episodio-1.mp4", 4000),
            new Video("creditos.mp4", 1000)
    };

    private static final long INTERVALO_ESPIA_MS = 500;

    public static void main(String[] args) throws InterruptedException {
        System.out.println("===== UDITflix - Pipeline de Transcodificacion =====");

        long secuencialMs = ejecutarSecuencial();
        long concurrenteMs = ejecutarConcurrente();

        imprimirResumen(secuencialMs, concurrenteMs);
    }

    /** RT3 · Modo secuencial real: llamar a run() NO crea hilos; todo corre en "main". */
    private static long ejecutarSecuencial() {
        System.out.println("\n--- MODO SECUENCIAL (run() en el hilo main) ---");
        long inicio = System.currentTimeMillis();
        for (Video v : LOTE) {
            new TareaTranscodificacion(v).run();
        }
        return System.currentTimeMillis() - inicio;
    }

    /** RT2 + RT4 · Modo concurrente: un hilo por vídeo, start() para lanzar y join() para esperar. */
    private static long ejecutarConcurrente() throws InterruptedException {
        System.out.println("\n--- MODO CONCURRENTE (start() + join()) ---");

        // 1. Crear los hilos (estado NEW): cada uno con su Runnable y su nombre propio.
        Thread[] workers = new Thread[LOTE.length];
        for (int i = 0; i < LOTE.length; i++) {
            workers[i] = new Thread(new TareaTranscodificacion(LOTE[i]), "WORKER-" + (i + 1));
        }

        StringBuilder inicial = new StringBuilder("[MAIN] Estado inicial:");
        for (Thread w : workers) {
            inicial.append(' ').append(w.getName()).append('=').append(w.getState());
        }
        System.out.println(inicial);

        // 2. Lanzar los workers y el espía.
        System.out.println("[MAIN] Lanzando workers...");
        long inicio = System.currentTimeMillis();
        for (Thread w : workers) {
            w.start();
            // Justo tras start() el hilo suele estar RUNNABLE (listo o arrancando).
            System.out.println("[MAIN] " + w.getName() + " tras start() = " + w.getState());
        }

        Thread espia = new Thread(new EspiaEstados(workers, INTERVALO_ESPIA_MS, inicio), "ESPIA");
        espia.setDaemon(true); // Ampliación: no impide que la JVM termine.
        espia.start();

        // 3. Esperar a TODOS los workers. Los join() van en un bucle aparte de los start():
        //    si fueran en el mismo bucle, volveríamos a tener ejecución secuencial.
        for (Thread w : workers) {
            w.join();
        }
        long duracion = System.currentTimeMillis() - inicio;

        // Esperamos también al espía para que su última traza (todo TERMINATED)
        // salga antes del resumen y no se mezcle con él.
        espia.join();
        return duracion;
    }

    private static void imprimirResumen(long secuencialMs, long concurrenteMs) {
        long masLento = 0;
        long suma = 0;
        for (Video v : LOTE) {
            masLento = Math.max(masLento, v.duracionMs());
            suma += v.duracionMs();
        }
        long ahorro = secuencialMs - concurrenteMs;
        double porcentaje = secuencialMs == 0 ? 0 : ahorro * 100.0 / secuencialMs;

        System.out.println("\n===== RESUMEN =====");
        System.out.printf("Teorico - suma de todas:     %5d ms%n", suma);
        System.out.printf("Teorico - el mas lento:      %5d ms%n", masLento);
        System.out.printf("Tiempo secuencial real:      %5d ms%n", secuencialMs);
        System.out.printf("Tiempo concurrente real:     %5d ms%n", concurrenteMs);
        System.out.printf("Ahorro:                      %5d ms (%.1f %%)%n", ahorro, porcentaje);
    }
}
