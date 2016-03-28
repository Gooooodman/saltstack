memcache_pkg:
  pkg.installed:
    - pkgs:
      - memcached.x86_64

memcache_service:  
  cmd.run:    
    - names:
      - /sbin/chkconfig --add memcached
      - /sbin/chkconfig  memcached on
    - unless: /sbin/chkconfig --list memcached
    - require:
      - pkg: memcache_pkg
  service.running:   
    - name: memcached
    - enable: True
    - reload: True