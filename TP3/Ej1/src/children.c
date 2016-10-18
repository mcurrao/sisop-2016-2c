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
