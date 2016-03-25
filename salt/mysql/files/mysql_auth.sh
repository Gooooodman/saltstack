#!/bin/bash
cp -r -p  /usr/local/mysql/share/english/errmsg.sys  /usr/share/
echo "设置密码" |tee -a /root/init_mysql.log
PASSWD=`date +'%s' | md5sum`;PASSWD=${PASSWD:0:8}; mkdir -p /data/save/ && echo ${PASSWD} > /data/save/mysql_root
echo ${PASSWD} |tee -a /root/init_mysql.log
install -o mysql -g mysql -d /data/mysql_data/;cd /data/mysql_data/;/usr/local/mysql/scripts/mysql_install_db --datadir=./ --basedir=/usr/local/mysql
i=`ps -ef |grep mysqld.pid |grep -v grep`
if [ -n "$i" ];then
  echo "mysqld startd" |tee -a /root/init_mysql.log
/usr/local/mysql/bin/mysqladmin -u root password  ${PASSWD}
#/usr/local/mysql/bin/mysql -u root -p"${PASSWD}" -e "show databases";

/usr/local/mysql/bin/mysql -u root -p"${PASSWD}" << EOF
grant all on *.* to admin@'localhost' identified by 'Admin#2015';
grant all on *.* to admin@'127.0.0.1' identified by 'Admin#2015'; 
grant all on *.* to root@'127.0.0.1' identified by "${PASSWD}"; 
delete from mysql.user where Password='';
flush privileges; 
EOF
    echo "mysql ok..." |tee -a /root/init_mysql.log  
else
 service mysqld start
#mysql -uroot -e "show databases;"
/usr/local/mysql/bin/mysqladmin -u root password  ${PASSWD}
#/usr/local/mysql/bin/mysql -u root -p"${PASSWD}" -e "show databases";

/usr/local/mysql/bin/mysql -u root -p"${PASSWD}" << EOF
grant all on *.* to admin@'localhost' identified by 'Admin#2015';
grant all on *.* to admin@'127.0.0.1' identified by 'Admin#2015'; 
grant all on *.* to root@'127.0.0.1' identified by "${PASSWD}"; 
delete from mysql.user where Password='';
flush privileges; 
EOF
    echo "mysql ok..." |tee -a /root/init_mysql.log
fi

