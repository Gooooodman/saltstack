#-*- coding: utf-8 -*-
vhost:
  {% if 'salt-minion' in grains['id'] %} 
  - name: www 
    target: /usr/local/nginx/conf/vhosts/vhost_www.conf
  {% else %}
  - name: bbs
    target: /usr/local/nginx/conf/vhosts/vhost_bbs.conf
  {% endif %}
