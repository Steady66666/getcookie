#!/bin/sh

#这个脚本是想远程链接服务器添加ck

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

jdck_file=/usr/share/jd_openwrt_script/script_config

#判读文件夹存在与否
if [ ! -d "/root/f253" ];then
	mkdir /root/f253
fi
if [ ! -d "/root/f307" ];then
	mkdir /root/f307
fi
if [ ! -d "/root/f204" ];then
	mkdir /root/f204
fi
if [ ! -d "/root/f304" ];then
	mkdir /root/f304
fi

action_task(){
echo -e "开始建立sftp连接。。。"
lftp -u root,angqin.xyz sftp://${IP} <<EOF
cd ${jdck_file}
lcd ${server_file}
get jdCookie.js
quit
EOF
echo -e "文件导入服务器成功。。。"
sleep 2
}

read -p "输入你获取到的ck：" you_cookie
read -p "选择你所输入ck的服务器（1.内部   2.外部   3.204   4.304）：" choose_server

if [ "$choose_server" == "1" ];then
	server_file=/root/f253
	IP=monkang.top:2599
	action_task
	echo -e "你选择了：内部"
	sleep 1
	echo -e "人员名单："
	head -n 15 ${server_file}/jdCookie.js | awk -F "pt_pin=" '{print $2}'
	sleep 2
	
	
	
elif [ "$choose_server" == "2" ];then
	server_file=/root/f307
	IP=monkang.top:2598
	action_task
	echo -e "你选择了：外部"
	sleep 1
	echo -e "人员名单："
	head -n 15 ${server_file}/jdCookie.js | awk -F "pt_pin=" '{print $2}'
	sleep 2
	
	
elif [ "$choose_server" == "3" ];then
	server_file=/root/f204
	IP=monkang.xyz:2599
	action_task
	echo -e "你选择了：204"
	sleep 1
	echo -e "人员名单："
	head -n 15 ${server_file}/jdCookie.js | awk -F "pt_pin=" '{print $2}'
	sleep 2
	
elif [ "$choose_server" == "4" ];then
	server_file=/root/f304
	IP=monkang.xyz:2598
	action_task
	echo -e "你选择了：304"
	sleep 1
	echo -e "人员名单："
	head -n 15 ${server_file}/jdCookie.js | awk -F "pt_pin=" '{print $2}'
	sleep 2
	
fi



#cookie操作（移植）
#添加更新cookie

addcookie(){
	echo -e "$yellow\n开始为你查找是否存在这个cookie，有就更新，没有就新增。。。$white\n"
	sleep 2
	new_pt=$(echo $you_cookie)
	pt_pin=$(echo $you_cookie | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}')
	pt_key=$(echo $you_cookie | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')

	if [ `cat ${server_file}/jdCookie.js | grep "$pt_pin" | wc -l` == "1" ];then
		echo -e "$green检测到 $yellow${pt_pin}$white 已经存在，开始更新cookie。。$white\n"
		sleep 2
		old_pt=$(cat ${server_file}/jdCookie.js | grep "$pt_pin" | sed -e "s/',//g" -e "s/'//g")
		old_pt_key=$(cat ${server_file}/jdCookie.js | grep "$pt_pin" | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
		sed -i "s/$old_pt_key/$pt_key/g" ${server_file}/jdCookie.js
		echo -e "$green 旧cookie：$yellow${old_pt}$white\n\n$green更新为$white\n\n$green   新cookie：$yellow${new_pt}$white\n"
		echo  "------------------------------------------------------------------------------"
	else
		echo -e "$green检测到 $yellow${pt_pin}$white 不存在，开始新增cookie。。$white\n"
		sleep 2
		cookie_quantity=$( cat ${server_file}/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		i=$(expr $cookie_quantity + 5)
		if [ $i == "5" ];then
			sed -i "5a \  '$you_cookie\'," ${server_file}/jdCookie.js
		else
			sed -i "$i a\  '$you_cookie\'," ${server_file}/jdCookie.js
		fi
		echo -e "\n已将新cookie：$green${you_cookie}$white\n\n插入到$yellow${server_file}/jdCookie.js$white 第$i行\n"
		cookie_quantity1=$( cat ${server_file}/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		echo  "------------------------------------------------------------------------------"
		echo -e "$yellow你增加了账号：$green${pt_pin}$white$yellow 现在cookie一共有$cookie_quantity1个，具体以下：$white"
		cat ${server_file}/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo  "------------------------------------------------------------------------------"
	fi
}
addcookie

upload_task(){
echo -e "开始建立sftp连接。。。"
lftp -u root,angqin.xyz sftp://${IP} <<EOF
cd ${jdck_file}
lcd ${server_file}
put jdCookie.js
quit
EOF
echo -e "文件上传成功。。。"
sleep 2
}
read -p "是否上传文件，还是继续添加（1.上传文件   2.继续添加）：" choose_keep
if [ "$choose_keep" == "1" ];then
	upload_task
else
	echo -e "退出重新进入脚本"
fi
