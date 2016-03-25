include:
  - mysql.install   

mysql_conf:
  file.managed:   
    - name: /etc/my.cnf
    - source: salt://mysql/files/my.cnf

mysql_auth:
  file.managed:
    - name: /root/mysql_auth.sh
    - source: salt://mysql/files/mysql_auth.sh
    - mode: 755

# mysql_set_pass:
#   cmd.run: 
#     - names:
#       - PASSWD=`date +'%s' | md5sum`;PASSWD=${PASSWD:0:8}; mkdir -p /data/save/ && echo ${PASSWD} > /data/save/mysql_root



mysql_service:  
  file.managed:
    - name: /etc/init.d/mysqld
    - user: root
    - mode: 755
    - source: salt://mysql/files/mysqld
  cmd.run:
    - names:
      - /sbin/chkconfig --add mysqld
      - /sbin/chkconfig  mysqld on 
    - unless: /sbin/chkconfig --list mysqld
  service.running:     #mysql是启动状态
    - name: mysqld
    - enable: True
    - reload: True
    - watch:
      - file: /etc/my.cnf



mysql_install:
  cmd.run:
    - names: 
      - bash /root/mysql_auth.sh
    - require: 
      - file: mysql_service
      - file: mysql_auth
#      - cmd: mysql_set_pass



# mysql_passwd:
#   cmd.run:
#     - names:
#       - echo "start set mysql" >> /root/start.log &&PASSWD=`cat /data/save/mysql_root`;/usr/local/mysql/bin/mysqladmin -u root password "${PASSWD}" && /usr/local/mysql/bin/mysql -u root -p"${PASSWD}" -e "grant all on *.* to admin@'localhost' identified by 'Admin#2015';grant all on *.* to admin@'127.0.0.1' identified by 'Admin#2015'; grant all on *.* to root@'127.0.0.1' identified by "${PASSWD}"; delete from mysql.user where Password='';flush privileges;" &&service mysqld restart && echo "end set mysql" >> /root/start.log
#     - require:
#       - cmd: mysql_install






