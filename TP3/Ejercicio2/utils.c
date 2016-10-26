#include <utils.h>

void imprimir(struct rusage *ru, time_t *t_total)
{
    printf("Tiempo reloj: %ld microsegundos\n", *t_total);
    printf("Tiempo CPU sistema total: %ld microsegundos\n", ru->ru_stime.tv_usec);
    printf("Tiempo CPU usuario total: %ld microsegundos\n", ru->ru_utime.tv_usec);
    printf("Cantidad de Soft Page Faults: %ld \n", ru->ru_minflt);
    printf("Cantidad de Hard Page Faults: %ld \n", ru->ru_majflt);
    printf("Operaciones de entrada (en bloques): %ld \n", ru->ru_inblock);
    printf("Operaciones de salida (en bloques): %ld \n", ru->ru_oublock);
    printf("Mensajes IPC enviados: %ld \n", ru->ru_msgsnd);
    printf("Mensajes IPC recibidos: %ld \n", ru->ru_msgrcv);
}

void calcularTiempos(struct timespec *inicio, struct timespec *fin, time_t *t_total)
{
    *t_total = fin->tv_nsec - inicio->tv_nsec;
    *t_total = *t_total / 1000 + 1000000 * (fin->tv_sec - inicio->tv_sec);
    // convierte a microsegundos
}

void setClientAddr(struct sockaddr_in *client_addr, const char *ip, int port)
{
    client_addr->sin_family = AF_INET;
    client_addr->sin_port = htons(port);
    client_addr->sin_addr.s_addr = inet_addr(ip);
    memset(&(client_addr->sin_zero), 0, sizeof(client_addr->sin_zero));
}

void setServerAddr(struct sockaddr_in *server_addr, int port)
{
    server_addr->sin_family = AF_INET; // AF_INET es la familia de IPs IPv4
    server_addr->sin_port = htons(port); // Convierte el puerto (protocolo)
    server_addr->sin_addr.s_addr = INADDR_ANY; // Acepta comunicacion a cualquier IP
    memset(&(server_addr->sin_zero), 0, sizeof(server_addr->sin_zero));
}