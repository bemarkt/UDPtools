#!/bin/bash
cat <<"EOF"

   ___    _____   _  _     ___   
  |_ _|  |_   _| | || |   / __|  
   | |     | |   | __ |  | (_ |  
  |___|   _|_|_  |_||_|   \___|  
_|"""""|_|"""""|_|"""""|_|"""""| 
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 

Author: ithg (fork from 233boy)
Github: https://github.com/ithg/UDPtools
EOF
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
none='\033[0m'

[[ $(id -u) != 0 ]] &&  echo -e " \n……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1 

sys_bit=$(uname -m)
Check_sys() {
	if [[ -f /etc/redhat-release ]]; then
		command="yum"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		command="apt-get"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		command="apt-get"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		command="yum"
	elif cat /proc/version | grep -q -E -i "debian"; then
		command="apt-get"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		command="apt-get"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		command="yum"
	else
	echo -e " \n${red}该脚本${none} 不支持你的系统。 \n" && exit 1
	fi
}

if [[ ${sys_bit} == "i386" || ${sys_bit} == "i686" ]]; then
	system_ver="_x86"
elif [[ ${sys_bit} == "x86_64" ]]; then
	system_ver="_amd64"
else
	echo -e " \n${red}不支持你的系统....${none}\n" && exit 1
fi
Install_BBR() {
	wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
}
Install() {
	Check_sys
	${command} install jq screen -y
	UDPspeeder_download_link=$(curl -s https://api.github.com/repos/wangyu-/UDPspeeder/releases | jq -r '.[0].assets[0].browser_download_url')
	UDP2raw_download_link=$(curl -s https://api.github.com/repos/wangyu-/udp2raw-tunnel/releases | jq -r '.[0].assets[0].browser_download_url')
	mkdir -p /tmp/UDPspeeder
	mkdir -p /tmp/UDP2raw
	if ! wget --no-check-certificate --no-cache -O "/tmp/UDPspeeder.tar.gz" ${UDPspeeder_download_link}; then
		echo -e "${red} 下载 UDPspeeder 失败！${none}" && exit 1
	fi
	if ! wget --no-check-certificate --no-cache -O "/tmp/UDP2raw.tar.gz" ${UDP2raw_download_link}; then
		echo -e "${red} 下载 UDP2raw 失败！${none}" && exit 1
	fi
	tar zxf /tmp/UDPspeeder.tar.gz -C /tmp/UDPspeeder
	tar zxf /tmp/UDP2raw.tar.gz -C /tmp/UDP2raw
	cp -f /tmp/UDPspeeder/speederv2${system_ver} /usr/bin/udpspeeder
	cp -f /tmp/UDP2raw/udp2raw${system_ver} /usr/bin/udp2raw
	chmod +x /usr/bin/udpspeeder
	chmod +x /usr/bin/udp2raw
	echo -n "请输入要加速的本地UDP端口:"
	read port
	screen -dmS udpspeeder
	screen -dmS udp2raw
	screen -x -S udpspeeder -p 0 -X stuff "udpspeeder -s -l127.0.0.1:7776  -r127.0.0.1:${port} -k "password" --mode 0 -f2:4 --timeout 0"
	screen -x -S udpspeeder -p 0 -X stuff $'\n'
	screen -x -S udp2raw -p 0 -X stuff "udp2raw -s -l0.0.0.0:7775 -r127.0.0.1:7776 -k "password" --raw-mode faketcp -a"
	screen -x -S udp2raw -p 0 -X stuff $'\n'
	Get_Server_IP
	if [[ -f /usr/bin/udpspeeder ]]; then
		clear
		echo -e " 
		${green} UDPspeeder&UDP2raw安装完成${none}

		${yellow}UDPspeeder${none}	使用端口：${red}本地：${green}7776${red}	远程：${green}1025
		${yellow}UDP2raw${none}		使用端口：${red}本地：${green}7775${red}	远程：${green}7776
		${yellow}${Server_IP_Info}

		${none}输入${yellow} screen -r udpspeeder ${none}查看udpspeeder
		${none}输入${yellow} screen -r udp2raw ${none}查看udp2raw

		脚本问题反馈: https://github.com/ithg/UDPspeeder/issues
		
		UDPspeeder 帮助或反馈: https://github.com/wangyu-/UDPspeeder
		UDP2raw 帮助或反馈: https://github.com/wangyu-/udp2raw-tunnel
		"
	else
		echo -e " \n$red安装失败...${none}\n"
	fi
	rm -rf /tmp/UDPspeeder
	rm -rf /tmp/UDPspeeder.tar.gz
}
Uninstall() {
	if [[ -f /usr/bin/udpspeeder ]] && [[ -f /usr/bin/udp2raw ]]; then
		screen -X -S udpspeeder quit
		screen -X -S udp2raw quit
		rm -rf /usr/bin/udpspeeder
		rm -rf /usr/bin/udp2raw
		echo -e " \n$green卸载完成...${none}\n" && exit 1
	else
		echo -e " \n$red你貌似没有安装 UDPspeeder&&UDP2raw ....无法卸载...${none}\n" && exit 1
	fi
}
Error() {

	echo -e "\n${red} 输入错误！${none}\n"

}
Get_Server_IP() {
	if [ ! -f /root/.ip.txt ]; then
		curl -s 'https://myip.ipip.net' >/root/.ip.txt
		Number_of_file_characters=$(cat .ip.txt | wc -L)
		if [ ${Number_of_file_characters} -gt '100' ]; then
			curl -s 'http://ip.cn' >/root/.ip.txt
		fi
	fi
	Server_IP_Info=$(sed -n '1p' /root/.ip.txt)
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
	echo " 3. 安装BBR"
	read -p "请选择[1-3]:" choose
	case $choose in
	1)
		if [[ -f /usr/bin/udpspeeder ]] && [[ -f /usr/bin/udp2raw ]]; then
			echo -e "${red} UDPspeeder&&UDP2raw已经存在！"
		else
			Install
		fi
		break
		;;
	2)
		Uninstall
		break
		;;
	3)
		Install_BBR
		;;
	*)
		Error
		;;
	esac
done