#include "cabecera.h"
int main(int argc, char **argv)
{
    FILE *f1;
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    char* f1_dir = argv[1];
    int agrabar[] = {0};
    printf("Toma estadisticas desde %s\n", f1_dir);
    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);
    f1 = fopen(f1_dir, "w");// Se crea el archivo
    int i;
    for(i = 0; i < CANT / 2; i++)
    {
        fwrite(agrabar, 2, 1, f1);
    }
    fflush(f1);
    fclose(f1);
    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);
    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);
    return 0;
}
