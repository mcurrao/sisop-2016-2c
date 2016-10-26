#include <utils.h>

int main()
{
    struct sockaddr_in server_addr;
    struct sockaddr_in client_addr;
    int server_socket;
    int client_socket;
    socklen_t client_addr_len;  
    char buffer[TAM_BUFFER];
    struct timespec inicio, fin;
    time_t t_total;
    struct rusage ru;
    printf("------------ Server ------------\n");

    clock_gettime(CLOCK_MONOTONIC_RAW, &inicio);

    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    // Intenta crear el socket
    if(server_socket == -1) {
        printf("No se pudo crear el socket\n");
        return 1;
    }

    setServerAddr(&server_addr, SERVER_PORT);

    bind(server_socket, (struct sockaddr *)&server_addr, sizeof(struct sockaddr_in));
    // Asocia el file descriptor (server_socket) con
    // la estructura de dirección del socket

    listen(server_socket, MAX_QUEUE);
    // El socket comienza a escuchar conexiones de clientes
    
    client_addr_len = sizeof(client_addr);
    client_socket = accept(server_socket, (struct sockaddr *) &client_addr, &client_addr_len);
    // Acepta la conexión de un cliente (bloqueante)

    // Conexion lista
    for (int i = 0; i < CANT_MENSAJES; ++i)
    {
        send(client_socket, "S", 1, 0);
        // Envía el mensaje al cliente
        memset(buffer, 0, sizeof(buffer));
        recv(client_socket, buffer, sizeof(buffer), 0);
        // Recibe el mensaje del cliente
    }

    close(client_socket);
    close(server_socket);
    // Destruye los sockets

    getrusage(RUSAGE_SELF, &ru);
    clock_gettime(CLOCK_MONOTONIC_RAW, &fin);

    calcularTiempos(&inicio, &fin, &t_total);
    imprimir(&ru, &t_total);

    return 0; 
};
