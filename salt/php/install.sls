php_pkg:
  pkg.installed:
    - pkgs:
      - php
      - php-pecl-memcache.x86_64
      - php-mysql.x86_64
      - php-gd.x86_64
      - php-mbstring.x86_64
      - php-fpm

php_service:  
  cmd.run:    
    - names:
      - /sbin/chkconfig --add php-fpm
      - /sbin/chkconfig  php-fpm on
    - unless: /sbin/chkconfig --list php-fpm
    - require:
      - pkg: php_pkg
  service.running:   
    - name: php-fpm
    - enable: True
    - reload: True
