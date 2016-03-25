ssh_pkg:
  pkg.installed:
    - pkgs:
      - openssh-server

log_file:
  cmd.run:
    - names:
      - /bin/mkdir -p /var/log/history-log/ && /bin/chmod 777 /var/log/history-log/ && shopt -s histappend && history -a && export HISTTIMEFORMAT="%F %T "
    - require:
      - pkg: ssh_pkg
    - unless: test -d /var/log/history-log/
