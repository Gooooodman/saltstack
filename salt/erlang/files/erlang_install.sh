#!/bin/bash
yum install -y unixODBC-devel libssl-dev libncurses5-dev libc6-dev byacc 

error() {
    echo "######################[错误] $1 ######################"
    [ $# -eq 1 ] && exit 1
}

echo "开始安装erlang..."
tar xf otp_src_R16B03-1.tar.gz
cd otp_src_R16B03-1 && make clean
if [ -z "`grep -rin 'OPENSSL_NO_EC2M' lib/crypto/c_src/crypto.c`" ]; then
    if !(sed -i '79 i\&&!defined(OPENSSL_NO_EC2M) \\' lib/crypto/c_src/crypto.c); then
        error "修改crypto.c出错!"
    fi
fi

if !(CHOST="x86_64-pc-linux-gnu" CFLAGS="-march=nocona -O2 -pipe -DOPENSSL_NO_EC=1" CXXFLAGS="-march=nocona -O2 -pipe" \
	&& ./configure --enable-kernel-poll --enable-threads --enable-smp-support --enable-hipe --enable-native-libs \
    && make \
    && make install); then
    error "安装erlang失败"
fi

echo "erlang install ok..." > /root/install_erlang.log


