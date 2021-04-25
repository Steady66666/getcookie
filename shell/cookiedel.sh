delcookie() {
	cookie_quantity=$(cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l)
	if [ `cat $script_dir/jdCookie.js | grep "$pt_pin" | wc -l` -ge "1" ];then
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
		cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "请填写你要删除的cookie（// 备注 或者pt_pin 名都行）：" you_cookie
		if [[ -z $you_cookie ]]; then
			echo -e "$red请不要输入空值。。。$white"
			exit 0
		fi
	
		sed -i "/$you_cookie/d" $script_dir/jdCookie.js
		clear
		echo "---------------------------------------------------------------------------"
		echo -e "$yellow你删除账号或者备注：$green${you_cookie}$white$yellow 现在cookie还有`cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | wc -l`个，具体以下：$white"
		cat $script_dir/jdCookie.js | sed -e "s/pt_key=XXX;pt_pin=XXX//g" -e "s/pt_pin=(//g" -e "s/pt_key=xxx;pt_pin=xxx//g"| grep "pt_pin" | sed -e "s/',//g" -e "s/'//g"
		echo "---------------------------------------------------------------------------"
		echo ""
		read -p "是否需要删除cookie（1.需要  2.不需要 ）：" cookie_continue
		if [ "$cookie_continue" == "1" ];then
			echo "请稍等。。。"
			delcookie
		elif [ "$cookie_continue" == "2" ];then
			echo "退出脚本。。。"
			exit 0
		else
			echo "请不要乱输，退出脚本。。。"
			exit 0
		fi
	else
		echo -e "$yellow你的cookie空空如也，比地板都干净，你想删啥。。。。。$white"
	fi

}
