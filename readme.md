# 基于skynet开发的游戏框架

## Server
通信流程

`client--->gateway--->login--->agentmgr--->newagent`

`client--->gateway--->agent--->one service`


## GameClient模拟`客户端`与`服务器`进行交互

编译Client:
```cpp
cd GameClient
mkdir build
cd build
cmake ..
make
cd bin
./main
```

## proto文件编写规则

每一个消息要在分配一个`唯一`的message_id

`caution`: message_id中的`key`为`msgName`的`大写`形式

## client向server发送消息
```
    input formate: [protoId] [data]...

    //for example login.proto send LOGIN_REQUEST

    //message_id = 1001, id = 1, pw = 123

    terminal input: 1001 1 123 
```

## 如果你编写了新的proto文件

服务器端:
1. 在proto文件夹下 执行 `sh complie_pb.sh`
2. `load_protocol.lua`的fileName表添加proto文件名
3. 在对应的`agent`服务添加`agent.client.msgName`方法

客户端:
1. GameClient/proto下 执行 `sh update_proto.sh`
2. `protocol.h` 包含对应的pb头文件,并且编写对应的封包函数与解包函数
3. `gameSocket.cpp`中`PACK_FUN_MAP(XX)`加入新消息id与解封包函数的映射




