#!/bin/bash

apt-get remove docker docker-engine docker.io containerd runc

apt-get update

apt-get install -y apt-transport-https ca-certificates curl nano mc gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

apt-get install -y docker-ce docker-ce-cli docker-compose containerd.io

apt-cache madison docker-ce

adduser ${USER} docker

usermod -a -G docker $(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)

curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

docker ps -a




