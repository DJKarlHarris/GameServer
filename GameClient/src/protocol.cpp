#include "./include/protocol.h"
#include "string.h"
#include "arpa/inet.h"
#include <vector>

std::string add_msgId(short msg_id, const std::string &data) {
    int length = data.length();
    std::vector<char> buf(length + 2);
    msg_id = htons(msg_id);
    memcpy(buf.data(), &msg_id, sizeof(msg_id));
    memcpy(buf.data() + sizeof(msg_id), data.data(), length);
    return std::string(buf.begin(), buf.end());
}

std::string login_request_pack(const std::vector<std::string>& vec) {
    login::login_request encode;
    encode.set_id(std::stoi(vec[1]));
    encode.set_pw(vec[2]);
    encode.set_result(1);

    std::string data;
    encode.SerializeToString(&data);

    //添加协议号
    return add_msgId(login::LOGIN_REQUEST, data); 
}

std::string work_request_pack(const std::vector<std::string>& vec) {
    //添加协议号
    return add_msgId(work::WORK_REQUEST, std::string()); 
}

std::string scene_enter_pack(const std::vector<std::string>& vec) {
    return add_msgId(scene::SCENE_ENTER, std::string());
}

std::string scene_leave_pack(const std::vector<std::string>& vec) {
    scene::scene_leave encode;
    encode.set_pid(std::stoi(vec[1]));

    std::string data;
    encode.SerializeToString(&data);

    return add_msgId(scene::SCENE_LEAVE, data);
}

std::string scene_shift_pack(const std::vector<std::string>& vec) {
    scene::scene_shift encode;
    encode.set_speedx(std::stoi(vec[1]));
    encode.set_speedy(std::stoi(vec[2]));

    std::string data;
    encode.SerializeToString(&data);

    return add_msgId(scene::SCENE_SHIFT, data);
}