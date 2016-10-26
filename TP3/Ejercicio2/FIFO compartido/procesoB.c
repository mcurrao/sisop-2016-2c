#include "utils.h"

int main()
{
    int f1, f2;
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    char msg[] = "B",
        buffer[TAM_BUFFER];
    char *fifo1 = "/tmp/fifo1";
    char *fifo2 = "/tmp/fifo2";
    printf("------------ Proceso B ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    for(int i = 0; i < CANT_MENSAJES; i++)
    {
        f1 = open(fifo1, O_RDONLY);
        read(f1, buffer, sizeof(buffer));
        // Recibe el mensaje del buffer
        close(f1);
        f2 = open(fifo2, O_WRONLY);
        write(f2, msg, sizeof(msg));
        // Envía el mensaje al buffer
        close(f2);
    }

    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);

    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);

    return 0;
}
