#!/bin/sh

function centos6_install(){
    yum install bind bind-utils
    
    chkconfig named on
    
    /etc/init.d/named start
    
    ps axf | grep named         # /usr/sbin/named -u named

    netstat -lpnt | grep named  # 53, 953
}

function centos6_setup(){
    local domain_name=$1
    local server_ip=$2
    
    cat > /etc/named/$domain_name <<EOF
zone "$domain_name" IN {
        type master;
        file "$domain_name.zone";
};
EOF

    echo "include \"/etc/named/$domain_name\";" >> /etc/named.conf
    sed "s/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { $server_ip; };/" -i /etc/named.conf
    sed 's/allow-query     { localhost; };/allow-query     { any; };/' -i /etc/named.conf

    cat > /var/named/$domain_name.zone <<EOF
\$TTL 1D
@       IN SOA  @ admin.$domain_name. (
                                        0
                                        1D
                                        1H
                                        1W
                                        3H )
        NS      ns.$domain_name.
ns      A       $server_ip
EOF
    chgrp named /var/named/$domain_name.zone
    named-checkzone $domain_name.zone /var/named/$domain_name.zone 
}

function centos6_zone_update(){
    local domain_name=$1
    local domain=$2
    local server_ip=$3
    echo "$domain      A       $server_ip" >> /var/named/$domain_name.zone
    chgrp named /var/named/$domain_name.zone
    named-checkzone $domain_name.zone /var/named/$domain_name.zone 
}

function centos6_main(){
    local type=$1

    case $type in
        install)
            centos6_install
            ;;
        setup)
            local domain_name=$2
            local server_ip=$3
            centos6_setup $domain_name $server_ip
            ;;
        update)
            local domain_name=$2
            local domain=$3
            local server_ip=$4
            centos6_zone_update $domain_name $domain $server_ip
            ;;
        *)
            cat <<EOF
Usage: $0 [type] ...

type:
    install  安装bind
        # bash $0 install
        
    setup   配置区域信息
        # bash $0 setup "域名区域名称" "域名服务器"
        
    update  更新zone，添加解析信息
        # bash $0 update "域名区域名称" "域名前缀" "服务器地址"
        
        
EOF
            ;;
    esac
}

grep -sq "^CentOS release 6." /etc/issue
[ $? -eq 0 ] && centos6_main $@
