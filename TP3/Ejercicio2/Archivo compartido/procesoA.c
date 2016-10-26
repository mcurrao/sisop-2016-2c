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
    char msg[] = "A", 
        ans[sizeof(msg)];
    printf("------------ Proceso A ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    // Se crean y/o vacian los archivos
    f1 = fopen(f1_dir, "w");
    fclose(f1);
    f2 = fopen(f2_dir, "w");
    fclose(f2);

    f1 = fopen(f1_dir, "a");
    f2 = fopen(f2_dir, "r");

    old_size = 0;
    for(int i = 0; i < CANT_MENSAJES / 2; i++)
    {
        fwrite(msg, 2, 1, f1);
        fflush(f1);
        while(fread(ans, 2, 1, f2) == 0);
    }

    fclose(f1);
    fclose(f2);

    //remove(f1_dir);
    //remove(f2_dir);

    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);

    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);
    
    return 0;
}
