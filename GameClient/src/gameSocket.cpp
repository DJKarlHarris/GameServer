#include "./include/gameSocket.h"
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <atomic>
#include <csignal>
#include <fcntl.h>
#include <thread>
#include <pthread.h>
#include <sstream>
#include <vector>
#include "./include/protocol.h"

#define PACK_FUN_MAP(XX) \
        XX(login::LOGIN_REQUEST, login_request_pack) \
        XX(work::WORK_REQUEST, work_request_pack) \
        XX(scene::SCENE_ENTER, scene_enter_pack) \
        XX(scene::SCENE_LEAVE, scene_leave_pack) \
        XX(scene::SCENE_SHIFT, scene_shift_pack)

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

    // msg_id ----> pack_func 根据msg_id 调用对应的封包函数
    std::string packMessage(const short& msg_id, const std::vector<std::string>& data) {
        switch(msg_id) {
#define XX(msg_id, pack_func) case msg_id : return pack_func(data);
        PACK_FUN_MAP(XX);
#undef XX
        }
        return std::to_string(msg_id);
    }
    

    void sendThread(int sockfd) {
        while(!stopFlag) {
            char message[1024];
            // id xx xxx 
            std::cin.getline(message, sizeof(message));
            std::istringstream iss(message);
            std::vector<std::string> data;
            std::string word;
            while(iss >> word) {
                data.push_back(word); 
            }

            std::string package{};
            short msg_id= stoi(data[0]);

            package = packMessage(msg_id, data);

            //ssize_t bytesSent = send(sockfd, message, strlen(message), 0);
            ssize_t bytesSent = sendMsg(sockfd, package.data(), package.length());

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

    //包长 + 协议号 + proto数据
    int sendMsg(int fd, const char* data, int length) {
        //开辟内存
        char* buf = (char*)malloc(length + 2);

        //做包头(包长度)
        int header = htons(length);
        //封包
        memcpy(buf, &header, 2);
        memcpy(buf + 2, data, length);

        //发送N字节数据
        int ret = writeN(fd, buf, length + 2);
        return ret;
    }

    int writeN(int fd, const char* data, int length) {
        int left = length;
        int writelen = 0;
        const char* ptr = data;
        while(left) {
            writelen = write(fd, ptr, left);
            if(writelen == -1) {
                perror("write");
                return -1;
            } else if(writelen == 0) {
                continue;
            }
            ptr += writelen;
            left -= writelen;
        }
        return length;
    }

}