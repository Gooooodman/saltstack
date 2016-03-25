include:
  - nginx.install     
{% set nginx_user = 'nginx' + ' ' + 'nginx' %}
nginx_conf:
  file.managed:   
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - template: jinja
    - defaults:
      nginx_user: {{ nginx_user }}      
      num_cpus: {{grains['num_cpus']}}  
nginx_service:  
  file.managed:
    - name: /etc/init.d/nginx
    - user: root
    - mode: 755
    - source: salt://nginx/files/nginx
  cmd.run:    
    - names:
      - /sbin/chkconfig --add nginx
      - /sbin/chkconfig  nginx on
    - unless: /sbin/chkconfig --list nginx
  service.running:   
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - file: /usr/local/nginx/conf/vhosts/*.conf