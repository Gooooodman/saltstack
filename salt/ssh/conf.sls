include:
  - ssh.install

ssh_key:
  cmd.run:
    - names: mkdir /root/.ssh
  file.managed:
    - name: /root/.ssh/authorized_keys
    - source: salt://ssh/files/authorized_keys
    - mode: 644
    - user: root

who_profile:
  file.managed:
    - name: /etc/profile
    - source: salt://ssh/files/profile
  cmd.run:
    - names: 
      - source /etc/profile


who_script:
  file.managed:
    - name: /root/whois_history.sh
    - source: salt://ssh/files/whois_history.sh
    - mode: 755
    - user: root


ssh_conf:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://ssh/files/sshd_config
  cmd.run:    
    - names:
      - /sbin/chkconfig --add sshd
      - /sbin/chkconfig  sshd on
    - unless: /sbin/chkconfig --list sshd
  service.running:   
    - name: sshd
    - enable: True
    - reload: True
    - watch:
      - file: /etc/ssh/sshd_config  

