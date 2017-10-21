#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
none='\e[0m'

[[ $(id -u) != 0 ]] && echo -e " \n哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

# 笨笨的检测方法
if [[ -f /usr/bin/apt-get ]] || [[ -f /usr/bin/yum ]]; then

	if [[ -f /usr/bin/yum ]]; then

		cmd="yum"

	fi

else

	echo -e " \n哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}\n" && exit 1

fi

if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
	speeder_ver="speederv2_x86"
elif [[ $sys_bit == "x86_64" ]]; then
	speeder_ver="speederv2_amd64"
else
	echo -e " \n$red毛支持你的系统....$none\n" && exit 1
fi

install() {
	$cmd install wget -y
	ver=$(curl -s https://api.github.com/repos/wangyu-/UDPspeeder/releases/latest | grep 'tag_name' | cut -d\" -f4)
	UDPspeeder_download_link="https://github.com/wangyu-/UDPspeeder/releases/download/$ver/speederv2_binaries.tar.gz"
	mkdir -p /tmp/UDPspeeder
	if ! wget --no-check-certificate -O "/tmp/UDPspeeder.tar.gz" $UDPspeeder_download_link; then
		echo -e "$red 下载 UDPspeeder 失败！$none" && exit 1
	fi
	tar zxf /tmp/UDPspeeder.tar.gz -C /tmp/UDPspeeder
	cp -f /tmp/UDPspeeder/$speeder_ver /usr/local/bin/speederv2
	chmod +x /usr/local/bin/speederv2
	if [[ -f /usr/local/bin/speederv2 ]]; then
		clear
		echo -e " 
		$green UDPspeeder 安装完成...$none

		输入$yellow speederv2 $none即可使用....

		备注...这个脚本仅负责安装和卸载...
		
		如何配置...后台运行...开鸡启动这些东西嘛...

		大胸弟....你自己解决咯...

		脚本问题反馈: https://github.com/233abc/UDPspeeder/issues
		
		UDPspeeder 帮助或反馈: https://github.com/wangyu-/UDPspeeder
		"
	else
		echo -e " \n$red安装失败...$none\n"
	fi
	rm -rf /tmp/UDPspeeder
	rm -rf /tmp/UDPspeeder.tar.gz
}
unistall() {
	if [[ -f /usr/local/bin/speederv2 ]]; then
		UDPspeeder_pid=$(ps ux | pgrep "speederv2")
		[ $UDPspeeder_pid ] && kill -9 $UDPspeeder_pid
		rm -rf /usr/local/bin/speederv2
		echo -e " \n$green卸载完成...$none\n" && exit 1
	else
		echo -e " \n$red大胸弟...你貌似毛有安装 UDPspeeder ....卸载个鸡鸡哦...$none\n" && exit 1
	fi
}
error() {

	echo -e "\n$red 输入错误！$none\n"

}
while :; do
	echo
	echo "........... UDPspeeder 快速一键安装 by 233abc.com .........."
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	read -p "请选择[1-2]:" choose
	case $choose in
	1)
		install
		break
		;;
	2)
		unistall
		break
		;;
	*)
		error
		;;
	esac
done
