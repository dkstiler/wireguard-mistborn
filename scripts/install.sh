#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

## ensure run as nonroot user
#if [ "$EUID" -eq 0 ]; then
MISTBORN_USER="mistborn"
if [ $(whoami) != "$MISTBORN_USER" ]; then
        echo "Creating user: $MISTBORN_USER"
        sudo useradd -s /bin/bash -d /home/$MISTBORN_USER -m -G sudo $MISTBORN_USER 2>/dev/null || true
        SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
        #echo "SCRIPTPATH: $SCRIPTPATH"
        FILENAME=$(basename -- "$0")
        #echo "FILENAME: $FILENAME"
        FULLPATH="$SCRIPTPATH/$FILENAME"
        #echo "FULLPATH: $FULLPATH"

        # SUDO
        case `sudo grep -e "^$MISTBORN_USER.*" /etc/sudoers >/dev/null; echo $?` in
        0)
            echo "$MISTBORN_USER already in sudoers"
            ;;
        1)
            echo "Adding $MISTBORN_USER to sudoers"
            sudo bash -c "echo '$MISTBORN_USER  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
            ;;
        *)
            echo "There was a problem checking sudoers"
            ;;
        esac
       
        # get git branch if one exists (default to master)
        pushd .
        cd $SCRIPTPATH
        GIT_BRANCH=$(git symbolic-ref --short HEAD || echo "master")
        popd

        sudo cp $FULLPATH /home/$MISTBORN_USER
        sudo chown $MISTBORN_USER:$MISTBORN_USER /home/$MISTBORN_USER/$FILENAME
        #sudo SSH_CLIENT="$SSH_CLIENT" MISTBORN_DEFAULT_PASSWORD="$MISTBORN_DEFAULT_PASSWORD" GIT_BRANCH="$GIT_BRANCH" -i -u $MISTBORN_USER bash -c "/home/$MISTBORN_USER/$FILENAME" # self-referential call
        sudo -E -i -u $MISTBORN_USER bash -c "/home/$MISTBORN_USER/$FILENAME" # self-referential call
        exit 0
fi

echo "Running as $USER"

# banner
echo -e "  ____      _                 ____  _  __"
echo -e " / ___|   _| |__   ___ _ __  | ___|| |/ /"
echo -e "| |  | | | | '_ \ / _ \ '__| |___ \| ' /"
echo -e "| |__| |_| | |_) |  __/ |     ___) | . \ "
echo -e " \____\__, |_.__/ \___|_|    |____/|_|\_\ "
echo -e "      |___/"
echo -e " __  __ _     _   _"
echo -e "|  \/  (_)___| |_| |__   ___  _ __ _ __"
echo -e "| |\/| | / __| __| '_ \ / _ \| '__| '_ \ "
echo -e "| |  | | \__ \ |_| |_) | (_) | |  | | | |"
echo -e "|_|  |_|_|___/\__|_.__/ \___/|_|  |_| |_|"
echo -e ""

# INPUT default admin password
if [ -z "${MISTBORN_DEFAULT_PASSWORD}" ]; then
    read -p "(Mistborn) Set default admin password: " -s MISTBORN_DEFAULT_PASSWORD
    echo
else
    echo "MISTBORN_DEFAULT_PASSWORD is already set"
fi

# SSH keys
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH keypair for $USER"
    ssh-keygen -t rsa -b 4096 -N "" -m pem -f ~/.ssh/id_rsa -q
    
    # Authorized keys
    echo "from=\"172.16.0.0/12,192.168.0.0/16,10.0.0.0/8\" $(cat ~/.ssh/id_rsa.pub)" > ~/.ssh/authorized_keys
else
    echo "SSH key exists for $USER"
fi

sudo rm -rf /opt/mistborn 2>/dev/null || true

# clone to /opt and change directory
echo "Cloning $GIT_BRANCH branch from mistborn repo"
sudo git clone https://gitlab.com/cyber5k/mistborn.git -b $GIT_BRANCH /opt/mistborn
sudo chown -R $USER:$USER /opt/mistborn
pushd .
cd /opt/mistborn
git submodule update --init --recursive

# initial load update package list
sudo apt-get update

# install figlet
sudo -E apt-get install -y figlet

# get os and distro
source ./scripts/subinstallers/platform.sh


# iptables
echo "Setting up firewall (iptables)"
if [ ! -f "/etc/iptables/rules.v4" ]; then
    echo "Setting iptables rules..."
    ./scripts/subinstallers/iptables.sh
else
    echo "iptables rules exist. Leaving alone."
fi


# SSH Server
sudo -E apt-get install -y openssh-server
#sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
#sudo sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
#sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
#sudo sed -i 's/PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo sed -i 's/#Port.*/Port 22/' /etc/ssh/sshd_config
sudo sed -i 's/Port.*/Port 22/' /etc/ssh/sshd_config
sudo systemctl enable ssh
sudo systemctl restart ssh

# Additional tools fail2ban
sudo -E apt-get install -y dnsutils fail2ban

# Install kernel headers
if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
    sudo -E apt install -y linux-headers-$(uname -r)
elif [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "raspios" ]; then
    sudo -E apt install -y raspberrypi-kernel-headers
else
    echo "Unsupported OS: $DISTRO"
    exit 1
fi

# Wireugard
source ./scripts/subinstallers/wireguard.sh

# Docker
source ./scripts/subinstallers/docker.sh
sudo systemctl enable docker
sudo systemctl start docker

# Unattended upgrades
sudo -E apt-get install -y unattended-upgrades

# Mistborn-cli (pip3 installed by docker)
figlet "Mistborn: Installing mistborn-cli"
sudo pip3 install -e ./modules/mistborn-cli

# Mistborn
# final setup vars

#IPV4_PUBLIC=$(ip -o -4 route show default | egrep -o 'dev [^ ]*' | awk '{print $2}' | xargs ip -4 addr show | grep 'inet ' | awk '{print $2}' | grep -o "^[0-9.]*"  | tr -cd '\11\12\15\40-\176' | head -1) # tail -1 to get last
IPV4_PUBLIC="10.2.3.1"


# generate production .env file
#if [ ! -d ./.envs/.production ]; then
./scripts/subinstallers/gen_prod_env.sh "$MISTBORN_DEFAULT_PASSWORD"
#fi

# unattended upgrades
sudo cp ./scripts/conf/20auto-upgrades /etc/apt/apt.conf.d/
sudo cp ./scripts/conf/50unattended-upgrades /etc/apt/apt.conf.d/

sudo systemctl stop unattended-upgrades
sudo systemctl daemon-reload
sudo systemctl restart unattended-upgrades

# setup Mistborn services

#if [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
#    # remove systemd-resolved lines
#    sudo sed -i '/.*systemd-resolved/d' /etc/systemd/system/Mistborn-base.service
#fi

sudo cp ./scripts/services/Mistborn-setup.service /etc/systemd/system/

# setup local volumes for pihole
sudo mkdir -p ../mistborn_volumes/
sudo chown -R root:root ../mistborn_volumes/
sudo mkdir -p ../mistborn_volumes/base/pihole/etc-pihole
sudo mkdir -p ../mistborn_volumes/base/pihole/etc-dnsmasqd
sudo mkdir -p ../mistborn_volumes/extra

# setup tls certs 
source ./scripts/subinstallers/openssl.sh
#sudo rm -rf ../mistborn_volumes/base/tls
#sudo mv ./tls ../mistborn_volumes/base/

# enable and run setup to generate .env
sudo systemctl enable Mistborn-setup.service
sudo systemctl start Mistborn-setup.service

# Download docker images while DNS is operable
sudo docker-compose -f base.yml pull || true
sudo docker-compose -f base.yml build

## disable systemd-resolved stub listener (creates symbolic link to /etc/resolv.conf)
if [ -f /etc/systemd/resolved.conf ]; then
    sudo sed -i 's/#DNSStubListener.*/DNSStubListener=no/' /etc/systemd/resolved.conf
    sudo sed -i 's/DNSStubListener.*/DNSStubListener=no/' /etc/systemd/resolved.conf
fi

## delete symlink if exists
if [ -L /etc/resolv.conf ]; then
    sudo rm /etc/resolv.conf
fi

## disable other DNS services
sudo systemctl stop systemd-resolved 2>/dev/null || true
sudo systemctl disable systemd-resolved 2>/dev/null || true
sudo systemctl stop dnsmasq 2>/dev/null || true
sudo systemctl disable dnsmasq 2>/dev/null || true

# hostname in /etc/hosts
sudo grep -qF "$(hostname)" /etc/hosts && echo "$(hostname) already in /etc/hosts" || echo "127.0.1.1 $(hostname) $(hostname)" | sudo tee -a /etc/hosts

# resolve all *.mistborn domains
echo "address=/.mistborn/10.2.3.1" | sudo tee ../mistborn_volumes/base/pihole/etc-dnsmasqd/02-lan.conf

# ResolvConf (OpenResolv installed with Wireguard)
#sudo sed -i "s/#name_servers.*/name_servers=$IPV4_PUBLIC/" /etc/resolvconf.conf
sudo sed -i "s/#name_servers.*/name_servers=10.2.3.1/" /etc/resolvconf.conf
sudo sed -i "s/name_servers.*/name_servers=10.2.3.1/" /etc/resolvconf.conf
#sudo sed -i "s/#name_servers.*/name_servers=127.0.0.1/" /etc/resolvconf.conf
sudo resolvconf -u 1>/dev/null 2>&1

echo "backup up original volumes folder"
sudo mkdir -p ../mistborn_backup
sudo tar -czf ../mistborn_backup/mistborn_volumes_backup.tar.gz ../mistborn_volumes 1>/dev/null 2>&1

# clean docker
echo "cleaning old docker volumes"
sudo systemctl stop Mistborn-base || true
sudo docker-compose -f /opt/mistborn/base.yml kill
sudo docker volume rm -f mistborn_production_postgres_data 2>/dev/null || true
sudo docker volume rm -f mistborn_production_postgres_data_backups 2>/dev/null || true
sudo docker volume rm -f mistborn_production_traefik 2>/dev/null || true
sudo docker volume prune -f 2>/dev/null || true

# clean Wireguard
echo "cleaning old wireguard services"
sudo ./scripts/env/wg_clean.sh

# start base service
sudo systemctl enable Mistborn-base.service
sudo systemctl start Mistborn-base.service
popd

figlet "Mistborn Installed"
echo "Watch Mistborn start: sudo journalctl -xfu Mistborn-base"
echo "Retrieve Wireguard default config for admin: sudo mistborn-cli getconf" 
