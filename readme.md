# 基于skynet开发的游戏框架

## Server
通信流程

`client--->gateway--->login--->agentmgr--->newagent`

`client--->gateway--->agent--->one service`


## GameClient模拟`客户端`与`服务器`进行交互

编译:
```cpp
cd GameClient
mkdir build
cd build
cmake ..
make
cd bin
./main
```

