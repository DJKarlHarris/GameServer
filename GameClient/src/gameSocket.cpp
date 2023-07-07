#include "./include/gameSocket.h"
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <atomic>
#include <csignal>
#include <fcntl.h>
#include <thread>
#include <pthread.h>

namespace karl {

    std::atomic<bool> stopFlag(false);
    pthread_t recvThreadId;
    pthread_t sendThreadId;

    void signalHandler(int signal) {
        if(signal == SIGINT) {
            std::cout << "Received SIGINT signal" << std::endl;
            stopFlag = true;
            pthread_cancel(karl::recvThreadId);
            pthread_cancel(karl::sendThreadId);
        }
    }

    void init_addr(sockaddr_in* server_addr, std::string server_ip, int server_port) {
        server_addr->sin_family = AF_INET;
        server_addr->sin_port = htons(server_port);
        if(inet_pton(AF_INET, server_ip.c_str(), &(server_addr->sin_addr)) <= 0) {
            std::cerr << "Invalid address !" << std::endl;
        }
    }

    void sendThread(int sockfd) {
        while(!stopFlag) {
            char message[1024];
            std::cin.getline(message, sizeof(message));

            std::string str(message);
            str.push_back('\r');
            str.push_back('\n');
            std::strcpy(message, str.c_str());

            ssize_t bytesSent = send(sockfd, message, strlen(message), 0);
            if(bytesSent == -1) {
                std::cerr << "Failed to send data" << std::endl;
                break;
            }

            if(strcmp(message, "q") == 0) {
                break;
            }
        }

        std::cout << "send Thread is exiting" << std::endl;
        stopFlag = true;
        pthread_cancel(karl::recvThreadId);
    } 

    void recvThread(int sockfd) {

        //int flags = fcntl(sockfd, F_GETFL, 0);
        //fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

        while(!stopFlag) {
            char buffer[1024];
            ssize_t bytesRecv = recv(sockfd, buffer, sizeof(buffer) - 1, 0);
            //if (bytesRecv == -1) {
            //    std::cerr << "Failed to receive data" << std::endl;
            //}
            if(bytesRecv == -1 or bytesRecv == 0) {
                std::cout << "server close the connection" << std::endl;
                break;
            }
            buffer[bytesRecv] = '\0';

            std::cout << "recv from server " << bytesRecv << " byte" << std::endl;
            if(bytesRecv > 0) {
                std::cout << buffer << std::endl;
            }
        }

        std::cout << "recv Thread is exiting" << std::endl;
    }
}