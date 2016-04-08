#nginx.tar.gz
nginx_source:
  file.managed:
    - name: /tmp/nginx-1.6.3.tar.gz
    - unless: test -e /tmp/nginx-1.6.3.tar.gz
    - source: salt://nginx/files/nginx-1.6.3.tar.gz

#pcre.tar.gz
pcre_source:
  file.managed:
    - name: /tmp/pcre-8.38.tar.gz
    - unless: test -e /tmp/pcre-8.38.tar.gz
    - source: salt://nginx/files/pcre-8.38.tar.gz

#extract
extract_nginx:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar -xf nginx-1.6.3.tar.gz -C /tmp
   - unless: test -d /tmp/nginx-1.6.3
    - require:
      - file: nginx_source


extract_pcre:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar -xf pcre-8.38.tar.gz -C /tmp
    - unless: test -d /tmp/pcre-8.38
    - require:
      - file: pcre_source


#user
nginx_user:
  user.present:
    - name: nginx
    - uid: 508
    - createhome: False
    - gid_from_name: True
    - shell: /sbin/nologin

#nginx_pkgs
nginx_pkg:
  pkg.installed:
    - pkgs:
      - gcc
      - openssl-devel
      - gcc-c++
      - zlib-devel

#nginx_compile
nginx_compile:
  cmd.run:
    - cwd: /tmp/nginx-1.6.3
    - names:
      - sed -i 's#CFLAGS="$CFLAGS -g"#CFLAGS="$CFLAGS "#' auto/cc/gcc && CHOST="x86_64-pc-linux-gnu" CFLAGS="-O3" CXX=gcc CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti" && ./configure --prefix=/usr/local/services/nginx  --with-http_addition_module --user=nginx --with-http_realip_module --with-poll_module --with-select_module --group=nginx  --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module  --with-pcre=/tmp/pcre-8.38 && make && make install
    - require:
      - cmd: extract_nginx
      - pkg: nginx_pkg
    - unless: test -d /usr/local/services/nginx

#cache_dir
cache_dir:
  cmd.run:
    - names:
      - chown -R nginx.nginx /usr/local/services/nginx/ && mkdir -p /usr/local/services/nginx/conf/conf.d
    - require:
      - cmd: nginx_compile

