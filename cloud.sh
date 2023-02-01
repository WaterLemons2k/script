#!/bin/bash
set -e
#https://github.com/ylx2016/Linux-NetSpeed/blob/master/tcp.sh
#https://github.com/longwangjiang/Oracle-warp/blob/main/multi.sh

#检查是否为root用户
[[ $(whoami) != "root" ]] && echo "请使用 root 用户运行!" && exit 1
 
#检查是否为KVM
[[ $(hostnamectl | grep Virtualization | awk '{print $2}') != "kvm" ]] && echo "仅支持 KVM!" && exit 1

#检查架构
if [[ $(arch) == "x86_64" ]]; then
    ARCH="amd64"
elif [[ $(arch) == "aarch64" ]]; then
    ARCH="arm64"
else
    echo "未知架构!" && exit 1
fi

#检查Debian版本
if cat /etc/debian_version 2>/dev/null | grep -E '10|11'; then

  #安装内核
  clear
  echo "Cloud 内核安装脚本 版本1.2.2"
  echo "开始安装 Cloud 内核..."
  DEBIAN_FRONTEND=noninteractive apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install linux-image-cloud-$ARCH linux-headers-cloud-$ARCH -y

  #卸载内核
  deb_total=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "cloud" | wc -l)
      if [ "${deb_total}" ] >"1"; then
        echo -e "发现${deb_total}个内核，开始卸载..."
        for ((integer = 1; integer <= ${deb_total}; integer++)); do
          deb_del=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "cloud" | head -${integer})
          echo -e "开始卸载${deb_del}内核..."
          DEBIAN_FRONTEND=noninteractive apt-get purge -y ${deb_del}
          DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
          echo -e "${deb_del}内核卸载完成，继续..."
        done
        echo -e "内核卸载完成，继续..."
      else
        echo -e " 内核数量不正确!" && exit 1
      fi
  deb_total=$(dpkg -l | grep linux-headers | awk '{print $2}' | grep -v "cloud" | grep -v "common" | wc -l)
      if [ "${deb_total}" ] >"1"; then
        echo -e "发现${deb_total}个headers内核，开始卸载..."
        for ((integer = 1; integer <= ${deb_total}; integer++)); do
          deb_del=$(dpkg -l | grep linux-headers | awk '{print $2}' | grep -v "cloud" | grep -v "common" | head -${integer})
          echo -e "开始卸载${deb_del}headers内核..."
          DEBIAN_FRONTEND=noninteractive apt-get purge -y ${deb_del}
	  DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
          echo -e "${deb_del}内核卸载完成，继续..."
        done
        echo -e "内核卸载完成，继续..."
      else
        echo -e " 内核数量不正确!" && exit 1
      fi
      
    echo "准备重启..."
    reboot
    
  else echo "仅支持 Debian 10/11!"
fi
