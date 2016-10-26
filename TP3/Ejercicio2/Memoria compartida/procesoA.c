#include <utils.h>

int main()
{
    char *msg = "A", ans;
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    sem_t *sem_x = sem_open("/sem_x", O_CREAT, 0666, 0),
            *sem_y = sem_open("/sem_y", O_CREAT, 0666, 0);
    // Crea los semáforos x e y
    int id = shmget((key_t)654, CANT_MENSAJES*sizeof(msg), IPC_CREAT | IPC_EXCL | 0666);
    // Crea la memoria compartida solo si no existe
    char *vector = (char *) shmat(id, NULL, 0);
    // Vincula la memoria compartida al vector
    printf("------------ Proceso A ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    for(int i = 0; i < CANT_MENSAJES; i++)
    {
        memcpy(&vector[i], msg, sizeof(*msg));
        // Copia el mensaje en la posición i
        sem_post(sem_x); // V(x)
        sem_wait(sem_y); // P(y)
        memcpy(&ans, &vector[i], sizeof(ans));
        // Lee el mensaje de la posición i
    }

    shmdt(vector);
    // Desvincula la memoria compartida
    shmctl(id, IPC_RMID, NULL);
    // Destruye la memoria compartida cuando todos los
    // procesos se desvincularon ya de ella

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
