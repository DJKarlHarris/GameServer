#include <iostream>
#include "../build/bin/proto_generate/login.pb.h"
#include "../build/bin/proto_generate/person.pb.h"
#include <string>

int main(){
    std::cout << "helloworld" << std::endl;
    login::Login login;
    login.set_id(1);
    login.set_pw("123");
    login.set_result(1);

    std::string data; 
    login.SerializeToString(&data);


    login::Login decode_login;
    decode_login.ParseFromString(data);
    std::cout << decode_login.id() << std::endl;
    std::cout << decode_login.pw() << std::endl;

    google::protobuf::ShutdownProtobufLibrary();

};