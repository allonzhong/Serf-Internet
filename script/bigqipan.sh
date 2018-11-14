#!/bin/bash
for i in {1..8};do
        for x in {1..4};do  #控制单行大小。对已有输出进行放大
                for n in {1..8};do
                        a=`echo $[$[$i+$n]%2]`
                        if [ $a -eq 0 ];then
                                echo -e "\e[43m" "" "" "" "" "" "" "" "\e[0m\c"
                        else
                                echo -e "\e[42m" "" "" "" "" "" "" "" "\e[0m\c"
                        fi
                done
                echo
        done
done
