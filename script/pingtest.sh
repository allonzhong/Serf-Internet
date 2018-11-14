#!/bin/bash
#
> /root/ip.log
for i in {0..6};do
    for n in {1..255};do
    {
    ping -c1 -w1 192.168."$i"."$n" &> /dev/null
    if [ $? -eq  0  ] ;then
    echo "ping 192.168."$i"."$n"  is up"  >> /root/ip.log
    fi
    }&
    done
done

