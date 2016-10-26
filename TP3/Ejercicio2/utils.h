#ifndef TP3EJ2_H
    #define TP3EJ2_H

    #define CANT_MENSAJES 1000
    #define TAM_BUFFER 100
    #define SERVER_PORT 5000
    #define SERVER_IP "192.168.0.108"
    #define MAX_QUEUE 5

    #include <stdio.h>
    #include <stdlib.h>

    #include <sys/types.h>
    #include <sys/stat.h>
    #include <sys/resource.h>
    #include <unistd.h>
    #include <time.h>

    #include <fcntl.h>

    #include <sys/ipc.h>
    #include <sys/shm.h>
    #include <semaphore.h>
    #include <string.h>

    #include <arpa/inet.h>
    #include <sys/socket.h>
    #include <netdb.h>
    #include <ctype.h>

    void imprimir(struct rusage *ru, time_t *t_total);
    void calcularTiempos(struct timespec *inicio, struct timespec *fin, time_t *t_total);
    void setClientAddr(struct sockaddr_in *client_addr, const char *ip, int port);
    // Incializa la estructura de dirección del cliente.
    void setServerAddr(struct sockaddr_in *server_addr, int port);
    // Incializa la estructura de dirección del servidor.
#endif
