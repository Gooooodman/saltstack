include:
  - nginx.install

{% for vhostname in pillar['vhost'] %}

{{vhostname['name']}}:
  file.managed:
    - name: {{vhostname['target']}}
    - source: salt://nginx/files/vhost.conf
    - target: {{vhostname['target']}}
    - template: jinja
    - defaults:
      log_name: {{vhostname['name']}}
    - watch_in:
      service: nginx

{% endfor %}
