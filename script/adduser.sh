#!/bin/bash
> /root/user.log
for i in {1..10};do    
    useradd user$i && echo user$i is created
    pass=$(cat /dev/urandom |tr -dc '0-9a-zA-Z!@_#?.,' |head -c 16)   #生成随机数
    echo user$i:---pass:$pass >> /root/user.log
    echo $pass |password --stdin user$i &> /dev/null
done
