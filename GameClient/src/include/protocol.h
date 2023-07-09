#ifndef PROTOCOL_H
#define PROTOCOL_H

#include "../../build/bin/proto_generate/login.pb.h"
#include <string>

    std::string login_request_pack(std::vector<std::string> vec);

#endif