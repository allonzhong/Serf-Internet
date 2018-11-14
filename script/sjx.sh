#!/bin/bash
for ((i = 1; i < 10; i++))
do
   for ((j = 10; j > i; j--))
   do  
      echo -n " ";
   done
   for ((m = 1; m <= i; m++))
   do  
       echo -n "$i "
   done
   echo ""
done
