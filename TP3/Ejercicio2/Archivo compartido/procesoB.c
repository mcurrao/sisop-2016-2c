#include <utils.h>

int main()
{
    FILE *f1, *f2;
    struct stat st;
    off_t old_size;
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    char f1_dir[] = "./file1";
    char f2_dir[] = "./file2";
    char msg[] = "B",
        ans[sizeof(msg)];
    printf("------------ Proceso B ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    f1 = fopen(f1_dir, "r");
    f2 = fopen(f2_dir, "a");

    old_size = 0;
    for(int i = 0; i < CANT_MENSAJES / 2; i++)
    {
        while(fread(ans, 2, 1, f1) == 0);
        fwrite(msg, 2, 1, f2);
        fflush(f2);
    }

    fclose(f1);
    fclose(f2);

    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);

    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);
    
    return 0;
}
