#include <utils.h>
#include <funciones.c>

// function que ejecuta cada thread
void * procesar_lectura(void *args) {
    int x;
    long sum=0;
    struct info *params = args;
    struct rusage consumo;

    //printf("Recorro el array de %d posiciones", params->dimension);
    for(x=0; x<params->dimension; x++) {
        sum+=params->numeros[x];
    }
    // obtengo estadísticas del proceso hijo
    getrusage(RUSAGE_THREAD, &consumo);
    printf("Estadísticas del thread n° %d\n", params->contador);
    imprimir_uso(&consumo);
    ret[params->contador] = consumo;
    printf("----------------------------------\n");
    pthread_exit(0);

    return NULL;
}

// function que ejecuta cada thread
void * procesar_escritura(void *args) {
    int x;
    struct info *params = args;
    struct rusage consumo;

    for(x=0; x<params->dimension; x++) {
        //printf("Multiplico %d por %d y me da %ld\n", params->numeros[x], params->num_unico, params->numeros[x]*params->num_unico);
        params->numeros[x]*=params->num_unico;
    }

    // obtengo estadísticas del proceso hijo
    getrusage(RUSAGE_THREAD, &consumo);
    printf("Estadísticas del thread n° %d\n", params->contador);
    imprimir_uso(&consumo);
    ret[params->contador] = consumo;
    printf("----------------------------------\n");
    pthread_exit(0);

    return NULL;
}

int main(void) {
    int err;
    int *ptr[1000];
    unsigned long long *numeros;
    int dimension = 50000;
    int x;

    struct rusage padre;
    struct rusage hijos;
    struct timespec tiempo_ini, tiempo_fin;
    time_t tiempo_total;
    int num_unico;

    // contador de inicio
    clock_gettime(CLOCK_MONOTONIC_RAW, &tiempo_ini);

    // inicializo la estructura de procesamiento
    numeros = malloc(dimension * sizeof(long long));
    srand(time(NULL));

    for(x=0; x<dimension; x++) {
        numeros[x] = rand()%10000;
    }


    // genero el numero único
    srand(time(NULL));
    num_unico = (rand()%100)+2;

    // parametros que se le pasan a cada hilo
    struct info parametros;
    parametros.dimension = dimension;
    parametros.numeros = numeros;
    parametros.num_unico = num_unico;

    // ejecución de los hilos
    for(x=0; x<1000; x++) {
        parametros.contador = x;
        //err = pthread_create(&tid[x], NULL, &procesar_lectura, &parametros);
        err = pthread_create(&tid[x], NULL, &procesar_escritura, &parametros);
        if (err != 0)
            printf("\nError al iniciar el thread :[%s]", strerror(err));

        pthread_join(tid[x], (void**)&(ptr[x]));

        // acumulo los resultados de rusage del hilo en la variable hijos
        hijos.ru_utime.tv_sec+=ret[x].ru_utime.tv_sec;
        hijos.ru_utime.tv_usec+=ret[x].ru_utime.tv_usec;
        hijos.ru_stime.tv_sec+=ret[x].ru_stime.tv_sec;
        hijos.ru_stime.tv_usec+=ret[x].ru_stime.tv_usec;
        hijos.ru_minflt+=ret[x].ru_minflt;
        hijos.ru_majflt+=ret[x].ru_majflt;
        hijos.ru_nsignals+=ret[x].ru_nsignals;
        hijos.ru_nvcsw+=ret[x].ru_nvcsw;
        hijos.ru_nivcsw+=ret[x].ru_nivcsw;
    }

    // obtengo estadísticas del padre
    getrusage(RUSAGE_SELF, &padre);

    // tiempo de finalización
    clock_gettime(CLOCK_MONOTONIC_RAW, &tiempo_fin);
    calcularTiempos(&tiempo_ini, &tiempo_fin, &tiempo_total);

    printf("Suma de las estadísticas de los procesos hijos \n");
    imprimir_uso(&hijos);
    printf("----------------------------------\n");

    printf("Estadísticas totales \n");
    printf("Tiempo reloj: %ld microsegundos\n", tiempo_total);
    printf("Tiempo reloj promedio: %ld microsegundos\n", tiempo_total/1000);
    printf("Tiempo CPU sistema total: %ld microsegundos\n", padre.ru_stime.tv_usec+hijos.ru_stime.tv_usec);
    printf("Tiempo CPU usuario total: %ld microsegundos\n", padre.ru_utime.tv_usec+hijos.ru_utime.tv_usec);
    printf("Tiempo CPU sistema promedio: %ld microsegundos\n", (padre.ru_stime.tv_usec+hijos.ru_stime.tv_usec)/1000);
    printf("Tiempo CPU usuario promedio: %ld microsegundos\n", (padre.ru_utime.tv_usec+hijos.ru_utime.tv_usec)/1000);
    printf("Cantidad de Soft Page Faults: %ld\n", padre.ru_minflt);
    printf("Cantidad de Hard Page Faults: %ld\n", padre.ru_majflt);
    printf("Cantidad de señales recibidas: %ld\n", padre.ru_nsignals);
    printf("Cambios de contexto voluntarios: %ld\n", padre.ru_nvcsw);
    printf("Cambios de contexto involuntarios: %ld\n", padre.ru_nivcsw);

    return 0;
}
