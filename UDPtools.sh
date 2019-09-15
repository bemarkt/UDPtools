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
	echo -e " \n${red}该脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}\n" && exit 1
fi

if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
	system_ver="_x86"
elif [[ $sys_bit == "x86_64" ]]; then
	system_ver="_amd64"
else
	echo -e " \n$red不支持你的系统....$none\n" && exit 1
fi

install() {
	$cmd install wget jq screen -y
	UDPspeeder_download_link=$(curl -s https://api.github.com/repos/wangyu-/UDPspeeder/releases | jq -r '.[0].assets[0].browser_download_url')
	UDP2raw_download_link=$(curl -s https://api.github.com/repos/wangyu-/udp2raw-tunnel/releases | jq -r '.[0].assets[0].browser_download_url')
	mkdir -p /tmp/UDPspeeder
	mkdir -p /tmp/UDP2raw
	if ! wget --no-check-certificate --no-cache -O "/tmp/UDPspeeder.tar.gz" $UDPspeeder_download_link; then
		echo -e "$red 下载 UDPspeeder 失败！$none" && exit 1
	fi
	if ! wget --no-check-certificate --no-cache -O "/tmp/UDP2raw.tar.gz" $UDP2raw_download_link; then
		echo -e "$red 下载 UDP2raw 失败！$none" && exit 1
	fi
	tar zxf /tmp/UDPspeeder.tar.gz -C /tmp/UDPspeeder
	tar zxf /tmp/UDP2raw.tar.gz -C /tmp/UDP2raw
	cp -f /tmp/UDPspeeder/speederv2$system_ver /usr/bin/udpspeeder
	cp -f /tmp/UDP2raw/udp2raw$system_ver /usr/bin/udp2raw
	chmod +x /usr/bin/udpspeeder
	chmod +x /usr/bin/udp2raw
	screen -dmS udpspeeder
	screen -dmS udp2raw
	screen -x -S udpspeeder -p 0 -X stuff "udpspeeder -s -l127.0.0.1:7776  -r127.0.0.1:1025 -k "password" --mode 0 -f2:4 --timeout 0"
	screen -x -S udpspeeder -p 0 -X stuff $'\n'
	screen -x -S udp2raw -p 0 -X stuff "udp2raw -s -l0.0.0.1:7775 -r127.0.0.1:7776 -k "password" --raw-mode faketcp -a"
	screen -x -S udp2raw -p 0 -X stuff $'\n'

	if [[ -f /usr/bin/udpspeeder ]]; then
		clear
		echo -e " 
		$green UDPspeeder&UDP2raw安装完成...$none

		输入$yellow udpspeeder $none使用udpspeeder....
		输入$yellow udp2raw $none使用udpspeeder

		脚本问题反馈: https://github.com/ithg/UDPspeeder/issues
		
		UDPspeeder 帮助或反馈: https://github.com/wangyu-/UDPspeeder
		UDP2raw 帮助或反馈: https://github.com/wangyu-/udp2raw-tunnel
		"
	else
		echo -e " \n$red安装失败...$none\n"
	fi
	rm -rf /tmp/UDPspeeder
	rm -rf /tmp/UDPspeeder.tar.gz
}
uninstall() {
	if [[ -f /usr/bin/udpspeeder ]] && [[ -f /usr/bin/udp2raw ]]; then
		UDPspeeder_pid=$(pgrep "udpspeeder")
		UDP2raw_pid=$(pgrep "udp2raw")
		[ $UDPspeeder_pid ] && kill -9 $UDPspeeder_pid
		[ $UDP2raw_pid ] && kill -9 $UDP2raw_pid
		rm -rf /usr/bin/udpspeeder
		rm -rf /usr/bin/udp2raw
		echo -e " \n$green卸载完成...$none\n" && exit 1
	else
		echo -e " \n$red大胸弟...你貌似没有安装 UDPspeeder&&UDP2raw ....卸载个鸡鸡哦...$none\n" && exit 1
	fi
}
error() {

	echo -e "\n$red 输入错误！$none\n"

}
while :; do
	echo
	echo "........... UDP工具 快速一键安装 by ithg .........."
	echo "........... fork from 233boy .........."
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	read -p "请选择[1-2]:" choose
	case $choose in
	1)
		if [[ -f /usr/bin/udpspeeder ]] && [[ -f /usr/bin/udp2raw ]]; then
			echo -e "$red UDPspeeder&&UDP2raw已经存在！"
		else
			install
		fi
		break
		;;
	2)
		uninstall
		break
		;;
	*)
		error
		;;
	esac
done
