#!/bin/sh
#
# Description: docker managment
#
# CHANGELOG:
#   2018-12-22 17:50:00 Leon "Original version"


function ubuntu_install(){
    local mirrors="https://mirrors.tuna.tsinghua.edu.cn"
    cat <<EOF > /etc/apt/sources.list
deb $mirrors/ubuntu/ xenial main restricted
deb $mirrors/ubuntu/ xenial-updates main restricted
deb $mirrors/ubuntu/ xenial universe
deb $mirrors/ubuntu/ xenial-updates universe
deb $mirrors/ubuntu/ xenial multiverse
deb $mirrors/ubuntu/ xenial-updates multiverse
deb $mirrors/ubuntu/ xenial-backports main restricted universe multiverse
deb $mirrors/ubuntu xenial-security main restricted
deb $mirrors/ubuntu xenial-security universe
deb $mirrors/ubuntu xenial-security multiverse
EOF
    apt-get update
    
    apt-get -y install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg | apt-key add -
    cat <<EOF > /etc/apt/sources.list.d/docker-ce.list
deb [arch=amd64] $mirrors/docker-ce/linux/ubuntu xenial stable
EOF
    
    apt-get update
    apt-get -y install docker-ce=18.06.1~ce~3-0~ubuntu
}

function ubuntu_setup(){
    sed 's/^ExecStart=.*/ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ --registry-mirror=https:\/\/docker.mirrors.ustc.edu.cn/' -i /lib/systemd/system/docker.service
    systemctl daemon-reload && systemctl restart docker
}


function ubuntu_main(){
    local type=$1

    case $type in
        install)
            ubuntu_install
            ;;
        setup)
            ubuntu_setup
            ;;
        *)
            cat <<EOF
Usage: $0 [type] ...

type:
    install  安装docker-ce
        # bash $0 install
        
    setup   配置docker-ce国内源
        # bash $0 setup

EOF
            ;;
    esac
}

grep -sq "^Ubuntu 16.04" /etc/issue
[ $? -eq 0 ] && ubuntu_main $@

