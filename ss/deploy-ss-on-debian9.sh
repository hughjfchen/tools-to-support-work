#!/usr/bin/env sh
SCRIPT_PATH_RAW=$(dirname $0)
# turn SCRIPT_PATH into absolute path
case ${SCRIPT_PATH_RAW} in
    /*) SCRIPT_PATH=${SCRIPT_PATH_RAW} ;;
    *) SCRIPT_PATH=$PWD/${SCRIPT_PATH_RAW} ;;
esac

my_arch=$(uname -m)
if [ ${my_arch} = "aarch64" ]; then
    docker_arm="arm64"
else
    docker_arm="amd64"
fi

docker_command=$(which docker)
if [ $? != 0 ]; then
    echo "no docker found, trying to install it"
    apt-get remove -y docker docker-engine docker.io containerd runc
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository "deb [arch=${docker_arm}] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
fi

docker_compose_command=$(which docker-compose)
if [ $? != 0 ]; then
    echo "no docker-compose found, trying to install it"
    apt-get update
    apt-get install -y docker-compose
fi

docker run -dt --name ssserver-kcptun -p 6443:6443 -p 6500:6500/udp mritd/shadowsocks -m "ss-server" -s "-s 0.0.0.0 -p 6443 -m chacha20-ietf -k Passw0rd" -x -e "kcpserver" -k "-t 127.0.0.1:6443 -l :6500 -mode fast2"
docker run -dt --name ssserver-obfs -p 8443:8443 -p 8500:8500/udp mritd/shadowsocks -m "ss-server" -s "-s 0.0.0.0 -p 8443 -m chacha20-ietf -k Passw0rd --plugin obfs-server --plugin-opts \"obfs=tls\""
