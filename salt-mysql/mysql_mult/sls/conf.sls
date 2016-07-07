include:
  - mysql.sls.install 

{%set MYSQL_DIR='/usr/local/mysql'%}
{%set MYSQLDATA_DIR=pillar['mysql']['mysqldata_dir']%}
{%set mysql_user=pillar['mysql']['mysql_user']%}
{%set mysql_password=pillar['mysql']['mysql_password']%}

{% for port in pillar['mysql']['ports']%}
/etc/init.d/mysqld_{{port}}:
  file.managed:
    - source: salt://mysql/files/mysqld
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - contest:
      port: {{port}}
      MYSQLDATA_DIR: {{MYSQLDATA_DIR}}
      MYSQL_DIR: {{MYSQL_DIR}}
  cmd.run:
    - names:
      - /sbin/chkconfig --add mysqld_{{port}}
      - /sbin/chkconfig --level 35 mysqld_{{port}} on
    - unless: /sbin/chkconfig --list mysqld_{{port}}

/etc/my_{{port}}.cnf:
  file.managed:
    - source: salt://mysql/files/my.cnf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - contest:
      port: {{port}}
      MYSQLDATA_DIR: {{MYSQLDATA_DIR}}
      MYSQL_DIR: {{MYSQL_DIR}}
    - unless: test -e /etc/my_{{port}}.cnf

{{MYSQLDATA_DIR}}/{{port}}/data:
  file.directory:
    - makedirs: True
    - user: mysql
    - group: mysql
    - recurse:
      - user
      - group

{{MYSQLDATA_DIR}}/{{port}}/binlog:
  file.directory:
    - makedirs: True
    - user: mysql
    - group: mysql
    - recurse:
      - user
      - group

init_mysql_{{port}}:
  cmd.run:
    - name: {{MYSQL_DIR}}/scripts/mysql_install_db --user=mysql --basedir={{MYSQL_DIR}} --datadir={{MYSQLDATA_DIR}}/{{port}}/data
    - require:
      - cmd: mysql_compile
      - file: {{MYSQLDATA_DIR}}/{{port}}/data
      - file: {{MYSQLDATA_DIR}}/{{port}}/binlog
    - unless: test -d {{MYSQLDATA_DIR}}/{{port}}/data/mysql

/etc/init.d/mysqld_{{port}} start:
  cmd.wait:
    - require:
      - file: /etc/my_{{port}}.cnf
      - file: /etc/init.d/mysqld_{{port}} 
    - watch:
      - cmd: init_mysql_{{port}}

init_passwd_{{port}}:
  cmd.wait:
    - names:
      - {{MYSQL_DIR}}/bin/mysql -u{{mysql_user}} -S /tmp/mysqld_{{port}}.sock -e "GRANT ALL PRIVILEGES ON *.* TO root@localhost IDENTIFIED BY '{{mysql_password}}' WITH GRANT OPTION;GRANT ALL PRIVILEGES ON *.* TO {{mysql_user}}@localhost IDENTIFIED BY '{{mysql_password}}' WITH GRANT OPTION;GRANT ALL PRIVILEGES ON *.* TO root@127.0.0.1 IDENTIFIED BY '{{mysql_password}}' WITH GRANT OPTION;delete from mysql.user where Password='';flush privileges;" && service mysqld_{{port}} restart
    - watch:
      - cmd: /etc/init.d/mysqld_{{port}} start

{%endfor%}
