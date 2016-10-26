#include <utils.h>

int main()
{
    char *msg = "B", ans;
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    sem_t *sem_x = sem_open("/sem_x", 0),
            *sem_y = sem_open("/sem_y", 0);
    // Abre los semáforos ya creados
    int id = shmget((key_t)654, CANT_MENSAJES*sizeof(msg), 0666);
    // Abre la memoria compartida
    char *vector = (char *) shmat(id, NULL, 0);
    // Vincula la memoria compartida al vector
    printf("------------ Proceso B ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    for(int i = 0; i < CANT_MENSAJES; i++)
    {
        sem_wait(sem_x); // P(x)
        memcpy(&ans, &vector[i], sizeof(ans));
        // Lee el mensaje de la posición i
        memcpy(&vector[i], msg, sizeof(*msg));
        // Copia el mensaje en la posición i
        sem_post(sem_y); // V(y)
    }

    shmdt(vector);
    // Desvincula la memoria compartida

    sem_close(sem_x);
    sem_close(sem_y);
    sem_unlink("/sem_x");
    sem_unlink("/sem_y");
    // Destruye los semáforos

    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);

    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);

    return 0;
}
