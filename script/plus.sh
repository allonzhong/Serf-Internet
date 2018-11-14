#!/bin/bash
for (( i=1 ;i<=9;i++ ));do
	for ((n=1;n<=9;n++)) ;do
	w=0
	w=$[$n*$i]
	if [ $n -le $i ];then
		echo -n " $i*$n=$w "
	fi
	done
    echo
done
