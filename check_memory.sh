#!/bin/bash

echo "Checking the memory..."

mem_total_kb=`grep MemTotal /proc/meminfo | awk '{print $2}'`
mem_total=$(($mem_total_kb/1024))

echo -e "Total Memory is : $mem_total \n"
echo "Current configurations:"
shared_buffers=`grep 'shared_buffers =' postgresql_conf | awk -F"=" '{print $2}'`
work_mem=`grep 'work_mem =' postgresql_conf | awk -F"=" '{print $2}'`
java_arg_2=`grep 'java_arg_2 =' nifi_conf | awk -F"=" '{print $2}'`
java_arg_3=`grep 'java_arg_3 =' nifi_conf | awk -F"=" '{print $2}'`

echo "shared_buffers = $shared_buffers" 
echo "work_mem = $work_mem"
echo "java_arg_2 = $java_arg_2"
echo -e "java_arg_3 = $java_arg_3"

if [ $(( $mem_total / 1024 )) -gt 30 ] && [ $(($mem_total / 1024)) -le 60 ] ; then
  min_shared_mem=$(echo $mem_total*13/100 | bc)
  min_work_mem=$(echo $mem_total*2/100 | bc)
  min_java_arg_2=$(echo $mem_total*13/100 | bc)
  min_java_arg_3=$(echo $mem_total*65/100 | bc)
elif [ $(($mem_total / 1024)) -gt 60 ] ; then
  min_shared_mem=$(echo $mem_total*13/100 | bc)
  min_work_mem=$(echo $mem_total*2/100 | bc)
  min_java_arg_2=$(echo $mem_total*13/100 | bc)
  min_java_arg_3=$(echo $mem_total*65/100 | bc)
else
	echo "There is no enought memory to run cQube!"
	exit
fi

min_shared_mem=$(echo $mem_total*13/100 | bc)
min_work_mem=$(echo $mem_total*2/100 | bc)
min_java_arg_2=$(echo $mem_total*13/100 | bc)
min_java_arg_3=$(echo $mem_total*65/100 | bc)

if [[ "$min_shared_mem" == "$shared_buffers" && "$min_work_mem" = "$work_mem" && "$min_java_arg_2" = "$java_arg_2" && "$min_java_arg_3" = "$java_arg_3" ]]; then
   echo "All good. No need to change any memory configuration."
else

   echo "cQube memory config are not matching with current memory size."

echo "New configurations:"    

echo "shared_buffers = ${min_shared_mem}MB"  
echo "work_mem = ${min_work_mem}MB"
echo "java_arg_2 = -Xmx${min_java_arg_2}m"   
echo "java_arg_3 = -Xmx${min_java_arg_3}m" 

while true; do
   read -p 'Do you want to apply the new change (y/n) ?: ' input
    case $input in
        [yY]*)
             sed -i "/shared_buffers/c\shared_buffers = ${min_shared_mem}MB" postgresql_conf
             sed -i "/work_mem/c\work_mem = ${min_work_mem}MB"  postgresql_conf
             sed -i "/java_arg_2/c\java_arg_2 = -Xms${min_java_arg_2}m" nifi_conf
             sed -i "/java_arg_3/c\java_arg_3 = -Xmx${min_java_arg_3}m" nifi_conf
             echo "Changes done successfully."

            break
            ;;

        [nN]*)
             echo "Operation Aborted. Nothing changed."
            exit 1
            ;;
         *)
            echo "Invalid input" >&2
    esac
done
fi
