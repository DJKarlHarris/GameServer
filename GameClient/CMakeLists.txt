cmake_minimum_required(VERSION 3.22)
PROJECT(client)

#add_executable(main ${SRCS} ${PROTO_SRCS} ${PROTO_HDRS})

#target_link_libraries(main protobuf::libprotobuf)

ADD_SUBDIRECTORY(src bin)
