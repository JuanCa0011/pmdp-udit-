/**
 * "Espía de Estados": cada cierto intervalo imprime getState() de cada worker.
 * Deja de espiar en cuanto todos los workers están en TERMINATED.
 */
public class EspiaEstados implements Runnable {

    private final Thread[] workers;
    private final long intervaloMs;
    private final long t0;

    public EspiaEstados(Thread[] workers, long intervaloMs, long t0) {
        this.workers = workers;
        this.intervaloMs = intervaloMs;
        this.t0 = t0;
    }

    @Override
    public void run() {
        try {
            while (true) {
                imprimirEstados();
                if (todosTerminados()) {
                    break;
                }
                Thread.sleep(intervaloMs);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private void imprimirEstados() {
        long transcurrido = System.currentTimeMillis() - t0;
        StringBuilder linea = new StringBuilder(String.format("[ESPIA +%5d ms]", transcurrido));
        for (int i = 0; i < workers.length; i++) {
            linea.append(String.format(" W%d=%-14s", i + 1, workers[i].getState()));
        }
        System.out.println(linea);
    }

    private boolean todosTerminados() {
        for (Thread w : workers) {
            if (w.getState() != Thread.State.TERMINATED) {
                return false;
            }
        }
        return true;
    }
}
