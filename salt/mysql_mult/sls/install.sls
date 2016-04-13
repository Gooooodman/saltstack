{%set MYSQL_DIR='/usr/local/mysql'%}
{%set mysql_version=pillar['mysql']['mysql_version']%}
{%set path=grains['path']%}
#install source mysql
mysql_source:
  file.managed:
    - name: /usr/local/src/mysql-{{mysql_version}}.tar.gz
    - unless: test -e /usr/local/src/mysql-{{mysql_version}}.tar.gz
    - source: salt://mysql/files/mysql-{{mysql_version}}.tar.gz

#gmock_source:
#  file.managed:
#    - name: /usr/local/src/gmock-1.6.0.zip
#    - unless: test -e /usr/local/src/gmock-1.6.0.zip
#    - source: salt://mysql/files/gmock-1.6.0.zip

#gperftools.tar.gz
gperftools_source:
  file.managed:
    - name: /usr/local/src/gperftools-2.0.tar.gz
    - unless: test -e /usr/local/src/gperftools-2.0.tar.gz
    - source: salt://mysql/files/gperftools-2.0.tar.gz

#libunwind
libunwind_source:
  file.managed:
    - name: /usr/local/src/libunwind-1.0.1.tar.gz
    - unless: test -e /usr/local/src/libunwind-1.0.1.tar.gz
    - source: salt://mysql/files/libunwind-1.0.1.tar.gz

#tar mysql-5.6.19.tar.gz
extract_mysql:
  cmd.run:
    - cwd: /usr/local/src
    - names:
      - tar xf mysql-{{mysql_version}}.tar.gz
    - unless: test -d /usr/local/src/mysql-{{mysql_version}}
    - require:
      - file: mysql_source

#extract_gmock:
#  cmd.wait:
#    - cwd: /usr/local/src/mysql-{{mysql_version}}
#    - names: 
#      - mkdir source_downloads
#      - unzip gmock-1.6.0.zip -d ./source_downloads
#    - watch:
#      - cmd: extract_mysql

extract_gperftools:
  cmd.run:
    - cwd: /usr/local/src
    - names:
      - tar xf gperftools-2.0.tar.gz
    - unless: test -d /usr/local/src/gperftools-2.0
    - require:
      - file: gperftools_source

extract_libunwind:
  cmd.run:
    - cwd: /usr/local/src
    - names:
      - tar xf libunwind-1.0.1.tar.gz
    - unless: test -d /usr/local/src/libunwind-1.0.1
    - require:
      - file: gperftools_source
  
mysql_user:
  user.present:
    - name: mysql
    - uid: 1024
    - createhome: False
    - gid_from_name: True
    - shell: /sbin/nologin

/var/run/mysqld:
  file.directory:
    - makedirs: True
    - user: mysql
    - group: mysql
    - recurse:
      - user
      - group

mysql_pkg:
  pkg.installed:
    - pkgs:
      - gcc
      - gcc-c++
      - autoconf
      - automake
      - zlib
      - zlib-devel
      - ncurses-devel
      - cmake
      - libtool-ltdl-devel
      - openssl
      - openssl-devel

libunwind_pkg:
  pkg.installed:
    - pkgs:
      - autoconf
      - libtool

mysql_compile:
  cmd.run:
    - cwd: /usr/local/src/mysql-{{mysql_version}}
    - names:
      - cmake . -DCMAKE_INSTALL_PREFIX={{MYSQL_DIR}} -DMYSQL_DATADIR={{MYSQL_DIR}}/data -DWITH_SSL=yes -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_DEBUG=0 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci && make -j  {{grains['num_cpus']}} && make install && echo "{{MYSQL_DIR}}/lib" >/etc/ld.so.conf.d/mysql_lib.conf
    - require:
      - pkg: mysql_pkg
      - cmd: extract_mysql
    - unless: test -x {{MYSQL_DIR}}/bin/mysql && {{MYSQL_DIR}}/bin/mysql -V | grep -o {{mysql_version}}

add_mysql_path:
  cmd.run:
    - name: if grep -qE "^PATH=.+" /etc/profile;then grep -q "{{MYSQL_DIR}}/bin" /etc/profile||sed -i 's@^PATH=@PATH={{MYSQL_DIR}}/bin:@' /etc/profile;else echo "PATH={{MYSQL_DIR}}/bin:{{path}}" >> /etc/profile;fi
    - unless: grep -qE "{{MYSQL_DIR}}/bin" /etc/profile
  
libunwind_compile:
  cmd.run:
   - cwd: /usr/local/src/libunwind-1.0.1
   - names:
     - CFLAGS=-fPIC ./configure && make clean && make -j {{grains['num_cpus']}} CFLAGS=-fPIC && make CFLAGS=-fPIC install
   - require:
     - cmd: extract_libunwind
     - cmd: mysql_compile
     - pkg: libunwind_pkg
   - unless: test -f /usr/local/lib/libtcmalloc.so

gperftools_compile:
  cmd.run:
    - cwd: /usr/local/src/gperftools-2.0
    - names:
      - ./configure && make clean && make -j {{grains['num_cpus']}} && make install && echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf && /sbin/ldconfig && sed -i '/^# executing mysqld_safe/a\export LD_PRELOAD=/usr/local/lib/libtcmalloc.so;' {{MYSQL_DIR}}/bin/mysqld_safe
    - unless: grep -q "libtcmalloc.so" {{MYSQL_DIR}}/bin/mysqld_safe
    - require:
      - cmd: libunwind_compile

     
