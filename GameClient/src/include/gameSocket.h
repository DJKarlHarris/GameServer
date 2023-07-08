#ifndef GAME_SOCKET_H
#define GAME_SOCKET_H

#include <arpa/inet.h>
#include <string>
#include <thread>

namespace karl {
    extern pthread_t recvThreadId;
    extern pthread_t sendThreadId;

    void signalHandler(int signal);

    void init_addr(sockaddr_in* server_addr, std::string server_ip, int server_port);

    void sendThread(int sockfd);

    void recvThread(int sockfd);

    int sendMsg(int fd, const char* data, int length);

    int writeN(int fd, const char* data, int length);
}

#endif