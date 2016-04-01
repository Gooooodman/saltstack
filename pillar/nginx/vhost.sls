#-*- coding: utf-8 -*-
vhost:
  {% if 'salt-minion' in grains['id'] %} 
  - name: www 
    target: /usr/local/services/nginx/conf/conf.d/vhost_www.conf
  {% else %}
  - name: bbs
    target: /usr/local/services/nginx/conf/conf.d/vhost_bbs.conf
  {% endif %}
