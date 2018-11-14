#!/bin/bash
for ((i=1;i<20;i++))
do
        for ((j=1;j<=i;j++))
do
                echo -n "♥"
        done
        echo
done
for ((i=1;i<19;i++))
do
        for ((j=19;j>i;j--))
do
                echo -n "♥"
        done
        echo
done
