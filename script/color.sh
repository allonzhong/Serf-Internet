#!/bin/bash
#彩色闪烁山角形
read -p "请输入三角形边长： " w
for (( i=1;i<=$w;i++ )); do
        for(( j=$w;j>$i;j--  ));do
                echo -n " "
        done
        for (( m=1;m<=i;m++   ));do
                we=`cat /dev/urandom |tr -dc '1-6' |head -c 1 `
                echo -e  "\033[3"$we";5m♥\033[0m\c"   #红色加闪烁
                done
        echo

done
