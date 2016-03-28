erlang_source:
  file.managed:
    - name: /tmp/otp_src_R16B03-1.tar.gz
    - unless: test -e /tmp/otp_src_R16B03-1.tar.gz
    - source: salt://erlang/files/otp_src_R16B03-1.tar.gz

  cmd.run:
    - cwd: /tmp
    - names:
      - tar -xf otp_src_R16B03-1.tar.gz -C /tmp


erlang_install:
  cmd.run:
    - cwd: /tmp/otp_src_R16B03-1
    - names:
      - sed -i '79 i\&&!defined(OPENSSL_NO_EC2M) \\' lib/crypto/c_src/crypto.c && CHOST="x86_64-pc-linux-gnu" CFLAGS="-march=nocona -O2 -pipe -DOPENSSL_NO_EC=1" CXXFLAGS="-march=nocona -O2 -pipe" && ./configure --enable-kernel-poll --enable-threads --enable-smp-support --enable-hipe --enable-native-libs && make clean && make && make install
    - require: 
      - cmd: erlang_source
    - unless: test -f /usr/local/bin/erl