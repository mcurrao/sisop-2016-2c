#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <pthread.h>
#include <unistd.h>
#include <signal.h>

#define RUN_AS_HEAVY_PROCESS 0
#define RUN_AS_READ 0
#define PROCESSING_UNITS_AMOUNT 1000
extern struct rusage usageStatistics;
struct thread_args {
    int* intArray;
    int arraySize;
    int randomNumber;
};

void playHeavy(int *intArray, int arraySize, int randomNumber);
void playLight(int *intArray, int arraySize, int randomNumber);
void* playLight_run_read(void *args);
void* playLight_run_write(void *args);

void doRead(int *intArray, int arraySize);
void doWrite(int *intArray, int arraySize, int randomNumber);
void printRusage(struct rusage* rusage);
void printClockDiff(struct timespec* timerStart, struct timespec* timerEnd);
void rusage_accumulate_child_data(struct rusage* childRusage);
