#include "main.h"
void playHeavy(int *intArray, int arraySize, int randomNumber) {
    int child_pid = fork();
    if(child_pid) {
        struct rusage child_rusage;
        wait3(NULL,0,&child_rusage);
        rusage_accumulate_child_data(&child_rusage);
        return;
    } else {
        if(RUN_AS_READ) {
            doRead(intArray, arraySize);
        } else {
            doWrite(intArray, arraySize, randomNumber);
        }
        exit(0);
    }
}

void playLight(int* intArray, int arraySize, int randomNumber) {
    pthread_t id_hilo;
    struct thread_args args;
    args.arraySize = arraySize;
    args.intArray = intArray;
    args.randomNumber = randomNumber;
    void* child_rusage;
    void* thread_execution_routine;
    if(RUN_AS_READ)
        thread_execution_routine = &playLight_run_read;
    else
        thread_execution_routine = &playLight_run_write;
    pthread_create(&id_hilo,NULL,thread_execution_routine,(void *)&args);
    pthread_join(id_hilo,&child_rusage);
    rusage_accumulate_child_data((struct rusage*)child_rusage);
    free(child_rusage);
}

void* playLight_run_read(void *args) {
    struct rusage myRusageAsChild;
    struct thread_args* arguments = (struct thread_args*)args;
    doRead(arguments->intArray, arguments->arraySize);
    getrusage(RUSAGE_SELF, &myRusageAsChild);
    return (void*)&myRusageAsChild;
}

void* playLight_run_write(void *args){
    struct rusage myRusageAsChild;
    struct thread_args* arguments = (struct thread_args*)args;
    doWrite(arguments->intArray, arguments->arraySize, arguments->randomNumber);
    getrusage(RUSAGE_SELF, &myRusageAsChild);
    return (void*)&myRusageAsChild;
}

void doRead(int *intArray, int size) {
    long int acum = 0;
    for(int i = 0; i < size; i++) {
        acum =+ intArray[i];
    }
}

void doWrite(int *intArray, int size, int randomNumber) {
    for(int i = 0; i < size; i++) {
        intArray[i] = intArray[i] * randomNumber;
    }
}

void rusage_accumulate_child_data(struct rusage* childData) {
    usageStatistics.ru_utime.tv_usec = usageStatistics.ru_utime.tv_usec + childData->ru_utime.tv_usec;
    usageStatistics.ru_utime.tv_sec = usageStatistics.ru_utime.tv_sec + childData->ru_utime.tv_sec;
    usageStatistics.ru_minflt = usageStatistics.ru_minflt + childData->ru_minflt;
    usageStatistics.ru_majflt = usageStatistics.ru_majflt + childData->ru_majflt;
    usageStatistics.ru_nsignals = usageStatistics.ru_nsignals + childData->ru_nsignals;
    usageStatistics.ru_nvcsw = usageStatistics.ru_nvcsw + childData->ru_nvcsw;
    usageStatistics.ru_nivcsw = usageStatistics.ru_nivcsw + childData->ru_nivcsw;
}
