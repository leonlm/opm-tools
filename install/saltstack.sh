#!/bin/sh
#
# Description: saltstack managment
#
# CHANGELOG:
#   2018-05-20 22:00:00 Leon "Original version"


function centos6_install(){
    cat <<EOF > /etc/yum.repos.d/saltstack.repo
[saltstack-repo]
name=SaltStack repo for RHEL/CentOS $releasever
baseurl=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/SALTSTACK-GPG-KEY.pub

EOF
    yum clean all
    yum install salt-master
    yum install salt-ssh
    yum install salt-api

    chkconfig --level 2345 salt-master on
    chkconfig --level 2345 salt-api on
}

function centos6_setup(){
    cat << EOF > /etc/salt/master
default_include: master.d/*.conf

file_roots:
  base:
    - /srv/salt/base/
  dev:
    - /srv/salt/dev/
  prod:
    - /srv/salt/prod/

pillar_roots:
 base:
   - /srv/pillar

EOF

    mkdir -p /srv/salt/base \
             /srv/salt/dev \
             /srv/salt/prod

    echo "Add User/Password: saltapi/saltapi"
    useradd -M -s /sbin/nologin saltapi
    echo "saltapi" | passwd saltapi --stdin
    
    echo "  Access Protocol: http"
    echo "             Port: 8888"
    cat <<EOF > /etc/salt/master.d/http.conf
rest_cherrypy:
  port: 8888
  disable_ssl: True

external_auth:
  pam:
    saltapi:
      - .*
EOF

    /etc/init.d/salt-master restart
    /etc/init.d/salt-api restart
}

function centos6_main(){
    local type=$1

    case $type in
        install)
            centos6_install
            ;;
        setup)
            centos6_setup
            ;;
        *)
            cat <<EOF
Usage: $0 [type] ...

type:
    install  安装 salt-master, salt-ssh和salt-api
        # bash $0 install
        
    setup   配置salt master和salt api
        # bash $0 setup

EOF
            ;;
    esac
}

grep -sq "^CentOS release 6." /etc/issue
[ $? -eq 0 ] && centos6_main $@

