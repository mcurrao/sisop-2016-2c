#ifndef CABECERA_H_INCLUDED
#define CABECERA_H_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <sys/time.h>
#include <time.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/types.h>
#define CANT 157286400
// 150MB de "datos"

void imprimir(struct rusage* ru, time_t* t_total);
void calcularTiempos(struct timespec *inicio, struct timespec *fin, time_t *t_total);

#endif // CABECERA_H_INCLUDED
