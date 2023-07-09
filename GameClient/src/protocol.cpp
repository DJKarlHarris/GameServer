#include "./include/protocol.h"
#include "string.h"
#include "arpa/inet.h"
#include <vector>

std::string login_request_pack(std::vector<std::string> vec) {
    login::login_request login_request_encode;
    login_request_encode.set_id(std::stoi(vec[0]));
    login_request_encode.set_pw(vec[1]);
    login_request_encode.set_result(1);

    std::string data;
    login_request_encode.SerializeToString(&data);

    //添加协议号
    int length = data.length();
    std::vector<char> buf(length + 2);
    short msg_id = htons(1001);
    memcpy(buf.data(), &msg_id, sizeof(msg_id));
    memcpy(buf.data() + sizeof(msg_id), data.data(), length);

    return std::string(buf.begin(), buf.end());
}