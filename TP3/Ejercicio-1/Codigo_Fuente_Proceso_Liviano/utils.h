#ifndef UTILS_H_INCLUDED
#define UTILS_H_INCLUDED

#define _GNU_SOURCE
#include<stdio.h>
#include<string.h>
#include<pthread.h>
#include<stdlib.h>
#include<unistd.h>
#include <time.h>
#include <sys/resource.h>
#include <sys/sysinfo.h>

void imprimir_uso(struct rusage *ru);
void calcularTiempos(struct timespec *inicio, struct timespec *fin, time_t *t_total);

// estructuras para los threads
pthread_t tid[1000];
struct rusage ret[1000];

// parametros para los threads
struct info {
    int dimension;
    unsigned long long *numeros;
    int contador;
    int num_unico;
};

#endif // UTILS_H_INCLUDED
