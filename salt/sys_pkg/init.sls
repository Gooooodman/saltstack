base_pkg:
  pkg.installed:
    - pkgs:
      - rsync 
      - gcc.x86_64 
      - gcc-c++.x86_64 
      - tcpdump 
      - expect.x86_64 
      - curl.x86_64 
      - vim-enhanced 
      - crontabs 
      - denyhosts 
      - lsof 
      - lrzsz 
      - wget 
      - unzip.x86_64 
      - perf 
      - strace 
      - dstat 
      - openssl-devel.x86_64 
      - ncurses-devel.x86_64 
      - ntpdate

Development tools:
  pkg.group_installed

sysctl:  
  file.managed:
    - name: /etc/sysctl.conf
    - user: root
    - source: salt://sys_pkg/files/sysctl.conf

bashrc:  
  file.managed:
    - name: /etc/bashrc
    - user: root
    - source: salt://sys_pkg/files/bashrc

nmon:
  file.managed:
    - name: /usr/bin/nmon
    - user: root
    - mode: 755
    - source: salt://sys_pkg/files/nmon_x86_64_centos6  



denyhosts_service:  
  file.managed:
    - name: /etc/denyhosts.conf
    - user: root
    - source: salt://sys_pkg/files/denyhosts.conf

  cmd.run:    
    - names:
      - /sbin/chkconfig --add denyhosts
      - /sbin/chkconfig  denyhosts on
    - unless: /sbin/chkconfig --list denyhosts

  service.running:   
    - name: denyhosts
    - enable: True
    - reload: True
    - watch:
      - file: /etc/denyhosts.conf
