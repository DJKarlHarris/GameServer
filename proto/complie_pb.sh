#!/bin/bash

# 指定protobuf编译器路径
#PROTOC_PATH=/path/to/protoc

# 指定输出目录
OUTPUT_DIR=./output

# 指定待编译的protobuf文件目录
PROTO_DIR=./input

# 遍历protobuf文件目录中的所有proto文件
for file in $PROTO_DIR/*.proto
do

    # xxx.proto
    filename=$(basename "$file")
    # xxx.pb
    output_filename="${filename%.*}.pb"
    output=${OUTPUT_DIR}"/"${output_filename}
    
    protoc --descriptor_set_out=$output $file

    exitcode=$?
    if [ $exitcode -ne 0 ]; then
        echo "$filename compiled failed"
        exit 1
    fi
    
    echo "$filename compiled successfully."
    #echo "Output file: $output_filename"
    #echo "-------------------------------------"
done