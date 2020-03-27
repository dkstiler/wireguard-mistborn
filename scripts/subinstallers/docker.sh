#!/bin/bash

# Docker
# dependencies
echo "Installing Docker dependencies"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Docker repo key
echo "Adding docker repository key"
if [ "$DISTRO" == "ubuntu" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
elif [ "$DISTRO" == "debian" ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
elif [ "$DISTRO" == "raspbian" ]; then
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
fi

# Docker repo to source list
echo "Adding docker to sources list"
if [ "$DISTRO" == "ubuntu" ]; then
    sudo add-apt-repository -y \
       "deb https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
elif [ "$DISTRO" == "debian" ]; then
    sudo add-apt-repository -y \
   "deb https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
elif [ "$DISTRO" == "raspbian" ]; then
    echo "deb [arch=armhf] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
     $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list
fi

# install Docker
echo "Installing docker"
sudo apt-get update

if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
elif [ "$DISTRO" == "raspbian" ]; then
    sudo apt install -y --no-install-recommends \
    docker-ce \
    cgroupfs-mount
fi

# Docker group
sudo usermod -aG docker $USER

# Docker Compose
echo "Installing Docker Compose"
#if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
#    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#    sudo chmod +x /usr/local/bin/docker-compose
#elif [ "$DISTRO" == "raspbian" ]; then
# Install required packages
sudo apt update
sudo apt install -y python python3-pip python3-setuptools libffi-dev python-backports.ssl-match-hostname python3-dev libssl-dev

# Install Docker Compose from pip
# This might take a while
sudo pip3 install docker-compose
#fi

