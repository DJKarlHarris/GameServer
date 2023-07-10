#ifndef PROTOCOL_H
#define PROTOCOL_H

#include "../../build/bin/proto_generate/login.pb.h"
#include "../../build/bin/proto_generate/work.pb.h"
#include "../../build/bin/proto_generate/scene.pb.h"

    std::string login_request_pack(const std::vector<std::string>& vec);

    std::string work_request_pack(const std::vector<std::string>& vec);

    std::string scene_enter_pack(const std::vector<std::string>& vec);

    std::string scene_leave_pack(const std::vector<std::string>& vec);

    std::string scene_shift_pack(const std::vector<std::string>& vec);
#endif