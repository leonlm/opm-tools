# BIND

> BIND is open source software that enables you to publish your Domain Name System (DNS) information on the Internet, and to resolve DNS queries for your users.  The name BIND stands for “Berkeley Internet Name Domain”, because the software originated in the early 1980s at the University of California at Berkeley.

> BIND is by far the most widely used DNS software on the Internet, providing a robust and stable platform on top of which organizations can build distributed computing systems with the knowledge that those systems are fully compliant with published DNS standards.

## 介绍
BIND(Berkeley Internet Name Domain)是目前使用最为广泛的DNS服务器软件, BIND是伯克利大学的域名（Berkeley Internet Name Domain），是因为该软件起源于1980年的加州大学伯克利分校。该软件由ISC(Internet Systems Consortium)维护
* 支持大多数操作系统（Linux，UNIX，Mac，Windows）
* 守护进程名称named
* 默认使用UDP，TCP协议，端口为53(domain) ,953(远程控制)

## CentOS6安装与配置
### install

**# bash bind.sh install**

### setup
主配置文件：
**\# vi /etc/named.conf**
```
options {
        listen-on port 53 { $ServerIP; };	# ServerIP为DNS服务器IP
		...
        allow-query     { any; };
        ...
};
...
include "/etc/named/$DomainName";		# 正向解析配置。DomainName为域名

```

#### 正向解析配置
> 根据域名查找对应的IP地址

1. 配置区域数据信息
**# vi /etc/named/$DomainName**		# DomainName为域名
```
zone "$DomainName" IN {
        type master;
        file "$DomainName.zone";
};
```

2. 配置解析数据信息
**# vi /var/named/$DomainName.zone**
```
$TTL 1D
@       IN SOA  @ admin.$DomainName. (
                                        0
                                        1D
                                        1H
                                        1W
                                        3H )
        NS      ns.$DomainName.
ns      A       $ServerIP
```

#### 反向解析



## DNS

> DNS域名解析服务（Domain Name System）是用于解析域名与IP地址对应关系的服务。

### 基本概念
* SOA记录
	表明此DNS名称服务器是该DNS域中的数据信息来源
    
* 域名服务器记录（NS记录）
	指定某域名由哪个NDS服务器来解析
    
* 主机记录（A记录）
	用于名称解析的重要记录，将特定的主机名映射到对应主机的IP地址

* 别名记录（CNAME记录）
	将某个别名指向到某个A记录上

* 邮件交换记录（MX记录）
	用于电子邮件程序发送邮件时根据收信人的地址后缀来定位邮件服务器

* IPv6主机记录（AAAA记录）
	与A记录对应，将特定的主机名映射到对应主机的IPv6地址

* 服务位置记录（SRV记录）
	用于定义提供特定服务的服务器的位置

* 反向解析记录（PTR记录）
	将IP地址映射到对应的域名，可以看成A记录的反向，IP地址的反向解析

* NAPTR记录
	提供了正则表达式方式去映射域名。用于ENUM查询
 

## 参考
https://www.isc.org/downloads/bind/
https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%90%8D%E7%B3%BB%E7%BB%9F
