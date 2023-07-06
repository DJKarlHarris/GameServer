#find_package(Protobuf REQUIRED)
#
##file(GLOB protobuf_files
##        proto/input/*.proto
##        )
#
##file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/output)
#
## 设置生成的pb.cc pb.h的输出路径
#set(PROTOBUF_GENERATE_CPP_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/output)
#
#file(GLOB PROTO_SRC_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../proto/input/*.proto)
#protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_SRC_FILE})
#
##aux_source_directory(src SRCS)
##set(SRCS main.cpp)
#file(GLOB SRCS *.cpp)
#ADD_EXECUTABLE(main ${SRCS} ${PROTO_SRCS} ${PROTO_HDRS})
#
#target_link_libraries(main ${Protobuf_LIBRARIES})
#

##########################

find_package(Protobuf REQUIRED)

set(PROTO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../proto/input")
file(GLOB PROTO_FILES ${CMAKE_CURRENT_SOURCE_DIR}/../proto/input/*.proto)

## 存放pb.cc 与pb.h的文件路径
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/proto_generate)

# 设置生成的源文件路径
set(GENERATED_FILES)
foreach(PROTO_FILE ${PROTO_FILES})
    get_filename_component(PROTO_NAME ${PROTO_FILE} NAME_WE)
    set(GENERATED_FILE "${CMAKE_CURRENT_BINARY_DIR}/proto_generate/${PROTO_NAME}.pb.cc" "${CMAKE_CURRENT_BINARY_DIR}/proto_generate/${PROTO_NAME}.pb.h")
    list(APPEND GENERATED_FILES ${GENERATED_FILE})
    add_custom_command(
        OUTPUT ${GENERATED_FILE}
        COMMAND protoc --cpp_out=${CMAKE_CURRENT_BINARY_DIR}/proto_generate -I${PROTO_DIR} ${PROTO_FILE}
        DEPENDS ${PROTO_FILE}
        COMMENT "Generating C++ files from ${PROTO_FILE}"
    )
endforeach()

# 添加生成的源文件到项目中
add_library(protolib ${GENERATED_FILES})
# 添加链接库
target_link_libraries(protolib
    ${Protobuf_LIBRARIES}
)

file(GLOB SRCS *.cpp)
ADD_EXECUTABLE(main ${SRCS})

target_link_libraries(main protolib)
