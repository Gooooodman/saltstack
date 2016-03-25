#mysql.tar.gz
mysql_source:
  file.managed:
    - name: /tmp/mysql-5.5.46.tar.gz
    - unless: test -e /tmp/mysql-5.5.46.tar.gz
    - source: salt://mysql/files/mysql-5.5.46.tar.gz

#gperftools.tar.gz
gperftools_source:
  file.managed:
    - name: /tmp/gperftools-2.0.tar.gz
    - unless: test -e /tmp/gperftools-2.0.tar.gz
    - source: salt://mysql/files/gperftools-2.0.tar.gz


#libunwind
libunwind_source:
  file.managed:
    - name: /tmp/libunwind-1.0.1.tar.gz
    - unless: test -e /tmp/libunwind-1.0.1.tar.gz
    - source: salt://mysql/files/libunwind-1.0.1.tar.gz

#extract
extract_mysql:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar -xf mysql-5.5.46.tar.gz -C /tmp
    - require:
      - file: mysql_source


extract_gperftools:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar -xf gperftools-2.0.tar.gz -C /tmp
    - require:
      - file: gperftools_source


extract_libunwind:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar -xf libunwind-1.0.1.tar.gz -C /tmp
    - require:
      - file: libunwind_source


#user
mysql_user:
  user.present:
    - name: mysql
    - uid: 27
    - createhome: False
    - gid_from_name: True
    - shell: /sbin/nologin

#mysql_pkgs
mysql_pkg:
  pkg.installed:
    - pkgs:
      - cmake
      - make
      - gcc-c++
      - perl
      - ncurses.x86_64
      - ncurses-devel.x86_64 
      - expect
      - lsof

libunwind_pkg:
  pkg.installed:
    - pkgs:
      - autoconf
      - libtool

#
#mysql_compile
mysql_compile:
  cmd.run:
    - cwd: /tmp/mysql-5.5.46
    - names:
      - cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DWITH_SSL=yes -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1  -DWITH_DEBUG=0 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/usr/local/mysql/data/  && make -j  {{grains['num_cpus']}} && make install && echo "PATH=/usr/local/mysql/bin:$PATH" >> /etc/profile && export PATH=$PATH:/usr/local/mysql/bin && /bin/cp -r -p /usr/local/mysql/bin/* /usr/bin/
    - require:
      - cmd: extract_mysql
      - pkg: mysql_pkg
    - unless: test -d /usr/local/mysql



libunwind_compile:
  cmd.run:
   - cwd: /tmp/libunwind-1.0.1
   - names:
     - CFLAGS=-fPIC ./configure && make clean && make -j {{grains['num_cpus']}} CFLAGS=-fPIC && make CFLAGS=-fPIC install 
   - require:
     - cmd: extract_libunwind
     - cmd: mysql_compile
     - pkg: libunwind_pkg
   - unless: test -f /usr/local/lib/libtcmalloc.so

gperftools_compile:
  cmd.run:
    - cwd: /tmp/gperftools-2.0
    - names:
      - ./configure && make clean && make -j {{grains['num_cpus']}} && make install && echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf && /sbin/ldconfig && sed -i '/^# executing mysqld_safe/a\export LD_PRELOAD=/usr/local/lib/libtcmalloc.so;' /usr/local/mysql/bin/mysqld_safe
    - unless: grep -q "libtcmalloc.so" /usr/local/mysql/bin/mysqld_safe
    - require: 
      - cmd: libunwind_compile
