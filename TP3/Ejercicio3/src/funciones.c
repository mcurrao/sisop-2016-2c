#include "cabecera.h"

void imprimir(struct rusage* ru, time_t* t_total)
{
    printf("Tiempo reloj: %ld microsegundos\n", *t_total);
    printf("Tiempo CPU sistema total: %ld microsegundos\n", ru->ru_stime.tv_usec);
    printf("Tiempo CPU usuario total: %ld microsegundos\n", ru->ru_utime.tv_usec);
    printf("Cantidad de Soft Page Faults: %ld \n", ru->ru_minflt);
    printf("Cantidad de Hard Page Faults: %ld \n", ru->ru_majflt);
    printf("Operaciones de entrada (en bloques): %ld \n", ru->ru_inblock);
    printf("Operaciones de salida (en bloques): %ld \n", ru->ru_oublock);
    printf("Mensajes IPC enviados: %ld \n", ru->ru_msgsnd);
}

void calcularTiempos(struct timespec *inicio, struct timespec *fin, time_t *t_total)
{
    *t_total = fin->tv_nsec - inicio->tv_nsec;
    *t_total = *t_total / 1000 + 1000000 * (fin->tv_sec - inicio->tv_sec);
    // convierte a microsegundos
}
