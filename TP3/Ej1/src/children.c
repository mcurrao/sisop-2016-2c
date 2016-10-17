#include "main.h"
void playHeavy(int *intArray, int arraySize, int randomNumber) {
    int child_pid = fork();
    if(child_pid) {
        wait3(NULL,NULL,NULL);
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
