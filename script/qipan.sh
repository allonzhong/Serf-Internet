#!/bin/bash
for n in {1..8};do
    for i in {1..8} ;do
        if [ $[$n%2]  -eq 0   ];then
            if [ $[$i%2]  -eq 0   ];then
                 echo -e "\033[41m  \033[0m\c"
            fi
            if [ $[$i%2] -ne 0   ] ;then
                  echo -e "\033[47m  \033[0m\c"
                
            fi
        else
             if [ $[$i%2]  -eq 0   ];then
                                  echo -e "\033[47m  \033[0m\c"
                        fi
                        if [ $[$i%2] -ne 0   ] ;then
                                 echo -e "\033[41m  \033[0m\c"
                        
                        fi

        fi
    done
    echo 
done
