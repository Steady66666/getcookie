#!/bin/sh

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

#找账号cookie信息
list_name(){
echo -e "正在查找所属服务器人员信息。。。"
if [ ! -z `grep "吴权" /usr/share/jd_openwrt_script/script_config/jdCookie.js` ];then
	echo -e "$red该服务器所属为：$green 204 $white"
	echo -e "$red该组人员信息为：$white"
	echo -e "$green 1.吴权  2.杨逸鑫小号  3.杨逸鑫  4.谢嘉冕小号  5.谢嘉冕  6.贺夕  7.吴浩然 $white"

elif [ ! -z `grep "马群" /usr/share/jd_openwrt_script/script_config/jdCookie.js` ];then
	echo -e "$red该服务器所属为：$green 304 $white"
	echo -e "$red该组人员信息为：$white"
	echo -e "$green 1.吕保锴女朋友   2.柯焰强   3.吕保锴   4.马群   5.杨煜成 $white"

elif [ ! -z `grep "大盆友哥哥" /usr/share/jd_openwrt_script/script_config/jdCookie.js` ];then
	echo -e "$red该服务器所属为：$green 253 内部 $white"
	echo -e "$red该组人员信息为：$white"
	echo -e "$green 1.大盆友哥哥  2.妈妈   3.爸爸   4.小号   5.周继耀  6. 廖春琳   7.妈妈小号   8.双菲   9.大爸 $white"

elif [ ! -z `grep "周继耀小号" /usr/share/jd_openwrt_script/script_config/jdCookie.js` ];then
	echo -e "$red该服务器所属为：$green 307 外部 $white"
	echo -e "$red该组人员信息为：$white"
	echo -e "$green 1.颜洋雷   2.秦侦洪   3.代永洋   4.胡海林   5.颜洋雷小号  6.周继耀小号 $white"

else
	echo -e "$red未知所属关系，请手动检查！$white"
fi
}

search_name(){
read -p "输入你想要查找的京东号主人（人名）：" jd_name
ckname=$(grep "$jd_name" /usr/share/jd_openwrt_script/script_config/jdCookie.js)

echo -e "你查找的名字是：$jd_number"
echo -e "获取到Cookie为：$ckname"
}

clear
list_name
search_name
