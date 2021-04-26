#!/bin/sh

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"



#删除cookie
delcookie() {
	cookie_quantity=$(cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
	if [ `cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | grep "$pt_pin" | wc -l` -ge "1" ];then
		echo "---------------------------------------------------------------------------"
		echo -e "		删除cookie"
		echo "---------------------------------------------------------------------------"
		echo -e "$green例子：$white"
		echo ""
		echo -e "$green pt_key=jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086;pt_pin=jd_10086; //二狗子$white"
		echo ""
		echo -e "$yellow 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：$green二狗子 $white"
		echo -e "$yellow 请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：$green jd_10086$white "
		echo "---------------------------------------------------------------------------"
		echo -e "$yellow你的cookie有$cookie_quantity个，具体如下：$white"
		cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：" you_cookie
		if [[ -z $you_cookie ]]; then
			echo -e "$red请不要输入空值。。。$white"
			exit 0
		fi
	
		sed -i "/$you_cookie/d" /usr/share/jd_openwrt_script/script_config/jdCookie.js
		clear
		echo "---------------------------------------------------------------------------"
		echo -e "$yellow你删除账号或者备注：$green${you_cookie}$white$yellow 现在cookie还有`cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l`个，具体以下：$white"
		cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "是否需要继续删除cookie（1.需要  2.返回上一层 ）：" cookie_continue
		if [ "$cookie_continue" == "1" ];then
			echo "请稍等。。。"
			delcookie
		else
			echo "返回上一层。。。"
			script_start
		fi
	else
		echo -e "$yellow你的cookie空空如也，比地板都干净，你想删啥。。。。。$white"
	fi

}


# head -n 15 /usr/share/jd_openwrt_script/script_config/jdCookie.js | awk -F "pt_pin=" '{print $2}' #输出账号和备注 但是有";'//"这一坨

#添加更新cookie
addcookie() {
	read -p "选择获取cookie方式（1.扫码  2.输入文本 ）：" cookie_way
	if [ "$cookie_way" == "1" ];then
		/usr/bin/node /usr/share/jd_openwrt_script/JD_Script/js/getJDCookie.js
		
	
	
	
		#这里是先运行获取到cookie得到/tmp/getcookie进行下去的if
		if [ `cat /tmp/getcookie.txt | wc -l` == "1"  ];then #wc -l统计行数
		clear
		you_cookie=$(cat /tmp/getcookie.txt)
		rm -rf /tmp/getcookie.txt
		echo -e "\n$green已经获取到cookie，稍等。。。$white"
		sleep 1
		fi
	else
		clear
		echo "---------------------------------------------------------------------------"
		echo -e "		新增cookie或者更新cookie"
		echo "---------------------------------------------------------------------------"
		echo ""
		echo -e "$green例子：$white"
		echo ""
		echo -e "$green pt_key=jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086jd_10086;pt_pin=jd_10086; //二狗子$white"
		echo ""
		echo -e "$yellow pt_key=$green密码  $yellow pt_pin=$green 账号  $yellow// 二狗子 $green(备注这个账号是谁的)$white"
		echo ""
		echo -e "$yellow 请不要乱输 $white"
		echo "---------------------------------------------------------------------------"
		read -p "请填写你获取到的cookie(一次只能一个cookie)：" you_cookie
		if [[ -z $you_cookie ]]; then
			echo -e "$red请不要输入空值。。。$white"
			exit 0
		fi
	fi
	echo -e "$yellow\n开始为你查找是否存在这个cookie，有就更新，没有就新增。。。$white\n"
	sleep 2
	new_pt=$(echo $you_cookie)
	pt_pin=$(echo $you_cookie | awk -F "pt_pin=" '{print $2}' | awk -F ";" '{print $1}')
	pt_key=$(echo $you_cookie | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')

	if [ `cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | grep "$pt_pin" | wc -l` == "1" ];then #关键词是pt_pin,检测到有一个一样( wc -l )的就执行
		echo -e "$green检测到 $yellow${pt_pin}$white 已经存在，开始更新cookie。。$white\n"
		sleep 2
		old_pt=$(cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | grep "$pt_pin" | sed -e "s/',//g" -e "s/'//g")#sed看不懂
		old_pt_key=$(cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | grep "$pt_pin" | awk -F "pt_key=" '{print $2}' | awk -F ";" '{print $1}')
		sed -i "s/$old_pt_key/$pt_key/g" /usr/share/jd_openwrt_script/script_config/jdCookie.js
		echo -e "$green 旧cookie：$yellow${old_pt}$white\n\n$green更新为$white\n\n$green   新cookie：$yellow${new_pt}$white\n"
		echo  "------------------------------------------------------------------------------"
	else
		echo -e "$green检测到 $yellow${pt_pin}$white 不存在，开始新增cookie。。$white\n"
		sleep 2
		cookie_quantity=$( cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		i=$(expr $cookie_quantity + 5)
		if [ $i == "5" ];then #这里行数判断不会
			sed -i "5a \  '$you_cookie\'," /usr/share/jd_openwrt_script/script_config/jdCookie.js
		else
			sed -i "$i a\  '$you_cookie\'," /usr/share/jd_openwrt_script/script_config/jdCookie.js
		fi
		echo -e "\n已将新cookie：$green${you_cookie}$white\n\n插入到$yellow/usr/share/jd_openwrt_script/script_config/jdCookie.js$white 第$i行\n"
		cookie_quantity1=$( cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
		echo  "------------------------------------------------------------------------------"
		echo -e "$yellow你增加了账号：$green${pt_pin}$white$yellow 现在cookie一共有$cookie_quantity1个，具体以下：$white"
		cat /usr/share/jd_openwrt_script/script_config/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo  "------------------------------------------------------------------------------"
	fi
	echo -e "完成"
	read -p "选择生效cookie还是继续添加（1.生效  2.回到上一层  任意键.继续添加）" cookie_act
	if [ "$cookie_act" == "1" ];then
		echo -e "重启并发中"
		sh $jd kill_ccr
		sh $jd update
		echo -e "重启完成"
		sleep 1
		echo -e "开始替换助力"
		sh /root/cpjd.sh
		echo -e "$green若无报错，脚本运行完毕，正在返回上一层 $white"
		script_start
	elif [ "$cookie_act" == "2" ];then
		echo -e "返回上一层中。。。"
		sleep 1
		script_start
	else
		echo -e "继续添加"
		sleep 1
		addcookie
	fi
}

#启动问候
script_start() {
read -p "选择是添加更新还是删除（1.添加更新  2.删除  3.退出  4.人员信息）：" start_way
if [ "$start_way" == "1" ];then
	echo -e "$green正在跳转： 添加更新$white"
	sleep 1
	addcookie
elif [ "$start_way" == "2" ];then
	echo -e "$green正在跳转： 删除$white"
	sleep 1
	delcookie
elif [ "$start_way" == "3" ];then
	echo "正在退出脚本"
	sleep 1
	exit 0
elif [ "$start_way" == "4" ];then
	head -n 15 /usr/share/jd_openwrt_script/script_config/jdCookie.js | awk -F "pt_pin=" '{print $2}'
	script_start
else
	echo -e "$red 无效输入：请输入1,2,3或4  $white"
	script_start
fi
}
script_start

