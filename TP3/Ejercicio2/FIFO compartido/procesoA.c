#include "utils.h"

int main()
{
    int f1, f2;
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    char msg[] = "A",
        buffer[TAM_BUFFER];
    char *fifo1 = "/tmp/fifo1";
    char *fifo2 = "/tmp/fifo2";
    printf("------------ Proceso A ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    mkfifo(fifo1, 0666);
    mkfifo(fifo2, 0666);
    // Crea los archivos FIFO

    for(int i = 0; i < CANT_MENSAJES; i++)
    {
        f1 = open(fifo1, O_WRONLY);
        write(f1, msg, sizeof(msg));
        // Envía el mensaje al buffer
        close(f1);
        f2 = open(fifo2, O_RDONLY);
        read(f2, (void *) buffer, sizeof(buffer));
        // Recibe el mensaje del buffer
        close(f2);
    }

    unlink(fifo1);
    unlink(fifo2);
    // Elimina los archivos FIFO

    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);

    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);

    return 0;
}
