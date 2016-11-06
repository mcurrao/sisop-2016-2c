#include <utils.h>

void imprimir_uso(struct rusage *ru) {
    printf("Tiempo CPU sistema total: %ld microsegundos\n", ru->ru_stime.tv_usec);
    printf("Tiempo CPU usuario total: %ld microsegundos\n", ru->ru_utime.tv_usec);
    printf("Cantidad de Soft Page Faults: %ld\n", ru->ru_minflt);
    printf("Cantidad de Hard Page Faults: %ld\n", ru->ru_majflt);
    printf("Cantidad de señales recibidas: %ld\n", ru->ru_nsignals);
    printf("Cambios de contexto voluntarios: %ld\n", ru->ru_nvcsw);
    printf("Cambios de contexto involuntarios: %ld\n", ru->ru_nivcsw);
}

void calcularTiempos(struct timespec *inicio, struct timespec *fin, time_t *t_total) {
    *t_total = fin->tv_nsec - inicio->tv_nsec;
    *t_total = *t_total / 1000 + 1000000 * (fin->tv_sec - inicio->tv_sec);
    // convierte a microsegundos
}
