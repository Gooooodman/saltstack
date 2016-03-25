#!/bin/bash
[ ! -d /var/log/history-log ] && printf "\033[31;1m/var/log/history-log目录不存在，脚本退出！\033[0m\n"
while true
do
read -p "想查看谁的历史记录，有以下名单:`echo;ls /var/log/history-log|sort|uniq;echo "请选择："`" name
[ ! -f /var/log/history-log/$name ] && printf "\033[31;1m/var/log/history-log/$name文件不存在，请重新选择！\033[0m\n" || { filename="/var/log/history-log/$name";printf "\033[32;2m现在查看$name的历史记录，如下：\033[0m\n";break; }
done
i=1
num=0
exec 11<$filename
while read line
do
fileline[$i]=$line
echo "${fileline[$i]}" | grep -qE "^#[0-9]{10}$" && time=`echo "${fileline[$i]}" | sed "s/#//g"` && timestring=$(date +"%Y%m%d-%H:%M:%S" -d "1970-01-01 UTC $time seconds") && fileline[$i]="$timestring" && printit=false && ((num++))
[ $printit = true ] && printf " $num %2s${fileline[(($i-1))]}: ${fileline[$i]} \n"
time=""
timestring=""
printit=true
((i++))
done <&11

exec 11>&-
