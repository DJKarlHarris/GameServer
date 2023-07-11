#include <iostream>
#include <string>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <thread>
#include <csignal>

#include "./include/test.h"
#include "include/gameSocket.h"


std::set<std::thread::id> threads;
int main(){

    //karl::test_proto();

    // register signal
    std::signal(SIGINT, karl::signalHandler);

    int clientfd = socket(AF_INET, SOCK_STREAM, 0);
    sockaddr_in server_addr{};    
    karl::init_addr(&server_addr, "127.0.0.1", 8001);

    if (connect(clientfd, (sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        std::cerr << "Connection Failed!" << std::endl;
        close(clientfd);
        return -1;
    }

    std::thread sendThreadObj(karl::sendThread, clientfd);
    std::thread recvThreadObj(karl::recvThread, clientfd);
    karl::sendThreadId = sendThreadObj.native_handle();
    karl::recvThreadId = recvThreadObj.native_handle();


    sendThreadObj.join();
    recvThreadObj.join();

    close(clientfd);

    return 0;
};