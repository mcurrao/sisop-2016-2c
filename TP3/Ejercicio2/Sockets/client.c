#include <utils.h>

int main()
{
    int server_socket;
    char buffer[TAM_BUFFER];
    struct sockaddr_in server_addr;
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    printf("------------ Client ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    // Intenta crear el socket
    if(server_socket == -1) {
        printf("No se pudo crear el socket\n");
        return 1;
    }

    setClientAddr(&server_addr, SERVER_IP, SERVER_PORT);
    if(connect(server_socket, (struct sockaddr *) &server_addr, sizeof(server_addr)) == -1) {
        // Intenta conectar al servidor
        printf("No se pudo conectar al servidor\n");
        return 1;
    }

    // Conexion lista
    for (int i = 0; i < CANT_MENSAJES; ++i)
    {
        memset(buffer, 0, sizeof(buffer));
        recv(server_socket, buffer, sizeof(buffer), 0);
        // Recibe el mensaje del servidor (bloqueante)
        send(server_socket, "C", 1, 0);
        // Envia el mensaje al servidor (no bloqueante)
    }

    close(server_socket);
    // Destruye el socket

    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);

    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);

    return 0;
}
