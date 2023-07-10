#ifndef TEST_H
#define TEST_H

#include <iostream>
#include "../../build/bin/proto_generate/login.pb.h"


namespace karl {
    void test_proto() {
        login::login_request encode_login_request;
        encode_login_request.set_id(1);
        encode_login_request.set_pw("123");
        encode_login_request.set_result(1);

        std::string data; 
        encode_login_request.SerializeToString(&data);


        login::login_request decode_login_request;
        decode_login_request.ParseFromString(data);
        std::cout << decode_login_request.id() << std::endl;
        std::cout << decode_login_request.pw() << std::endl;

        google::protobuf::ShutdownProtobufLibrary();
    }
}


#endif