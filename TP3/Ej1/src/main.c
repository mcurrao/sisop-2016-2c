#include "main.h"
struct rusage usageStatistics;
int main(int argc, char **argv)
{
    if ( argc != 2 )
    {
        printf( "usage: %s count", argv[0] );
        return 2;
    }
    int positions = atoi(argv[1]);
    int *array = calloc(positions, sizeof(int));
    for(int i=0; i<positions; i++)
    {
        array[i]=(rand()%100)+1;
    }
    getrusage(RUSAGE_SELF, &usageStatistics);

    struct timespec requestStart, requestEnd;
    clock_gettime(CLOCK_MONOTONIC_RAW, &requestStart);
    int uniqueRandomNumber = (rand()%99)+2;
    for(int j = 0; j < PROCESSING_UNITS_AMOUNT; j++) {
        if(RUN_AS_HEAVY_PROCESS)
            playHeavy(array, positions, uniqueRandomNumber);
        else
            playLight(array, positions, uniqueRandomNumber);

    }
    clock_gettime(CLOCK_MONOTONIC_RAW, &requestEnd);
    printRusage(&usageStatistics);
    printClockDiff(&requestStart, &requestEnd);
    return 0;
}

void printRusage(struct rusage* rusage) {
    long int userCPUTime=rusage->ru_utime.tv_usec+rusage->ru_utime.tv_sec*1000000;
    long int systemCPUTime=rusage->ru_stime.tv_usec+rusage->ru_stime.tv_sec*1000000;
    long int systemCPUTime_avg = systemCPUTime / PROCESSING_UNITS_AMOUNT;
    long int userCPUTime_avg = userCPUTime / PROCESSING_UNITS_AMOUNT;

    printf("\nTiempo CPU sistema total:\t\t%ld microsegundos",systemCPUTime);
    printf("\nTiempo CPU usuario total:\t\t%ld microsegundos",userCPUTime);
    printf("\nTiempo CPU sistema promedio:\t\t%ld microsegundos/unidad de procesamiento",systemCPUTime_avg);
    printf("\nTiempo CPU usuario promedio:\t\t%ld microsegundos/unidad de procesamiento",userCPUTime_avg);
    printf("\nCantidad de Soft Page Faults:\t\t%ld",rusage->ru_minflt);
    printf("\nCantidad de Hard Page Faults:\t\t%ld",rusage->ru_majflt);
    printf("\nCantidad de señales emitidas:\t\t%ld",rusage->ru_nsignals);
    printf("\nCambios de contexto voluntarios:\t%ld",rusage->ru_nvcsw);
    printf("\nCambios de contexto involuntarios:\t%ld\n",rusage->ru_nivcsw);
}

void printClockDiff(struct timespec* startTime, struct timespec* endTime) {
    double startTimeInSeconds = (startTime->tv_sec) + (startTime->tv_nsec / 1.0e9);
    double endTimeInSeconds = (endTime->tv_sec) + (endTime->tv_nsec / 1.0e9);
    double elapsedTime = endTimeInSeconds - startTimeInSeconds;
    printf("\nTiempo de ejecucion transcurrido:\t%0.3f s", elapsedTime);
}
