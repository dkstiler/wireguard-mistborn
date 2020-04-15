#!/bin/bash

set -e

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
        sudo SSH_CLIENT="$SSH_CLIENT" MISTBORN_DEFAULT_PASSWORD="$MISTBORN_DEFAULT_PASSWORD" GIT_BRANCH="$GIT_BRANCH" MISTBORN_INSTALL_COCKPIT="$MISTBORN_INSTALL_COCKPIT" -i -u $MISTBORN_USER bash -c "/home/$MISTBORN_USER/$FILENAME" # self-referential call
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

# Install Cockpit?
if [ -z "${MISTBORN_INSTALL_COCKPIT}" ]; then
    read -p "Install Cockpit (a somewhat resource-heavy system management graphical user interface)? [Y/n]: " MISTBORN_INSTALL_COCKPIT
    echo
    MISTBORN_INSTALL_COCKPIT=${MISTBORN_INSTALL_COCKPIT:-Y}
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
sudo apt-get install -y figlet

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
sudo apt-get install -y openssh-server
sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Additional tools fail2ban
sudo apt-get install -y dnsutils fail2ban

# Install kernel headers
if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
    sudo apt install -y linux-headers-$(uname -r)
elif [ "$DISTRO" == "raspbian" ]; then
    sudo apt-get install -y raspberrypi-kernel-headers
fi

# Wireugard
source ./scripts/subinstallers/wireguard.sh

# Docker
source ./scripts/subinstallers/docker.sh

# Unattended upgrades
sudo apt-get install -y unattended-upgrades

# Cockpit
if [[ "$MISTBORN_INSTALL_COCKPIT" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # install cockpit
    source ./scripts/subinstallers/cockpit.sh
fi

# Mistborn
# final setup vars
iface=$(ip -o -4 route show to default | egrep -o 'dev [^ ]*' | awk 'NR==1{print $2}')
figlet "Mistborn default NIC: $iface"

#IPV4_PUBLIC=$(ip -o -4 route show default | egrep -o 'dev [^ ]*' | awk '{print $2}' | xargs ip -4 addr show | grep 'inet ' | awk '{print $2}' | grep -o "^[0-9.]*"  | tr -cd '\11\12\15\40-\176' | head -1) # tail -1 to get last
IPV4_PUBLIC="10.2.3.1"

# clean
if [ -f "/etc/systemd/system/Mistborn-base.service" ]; then
    sudo systemctl stop Mistborn*.service 2>/dev/null || true
    sudo systemctl disable Mistborn*.service 2>/dev/null || true
fi

sudo docker volume rm -f mistborn_production_postgres_data 2>/dev/null || true
sudo docker volume rm -f mistborn_production_postgres_data_backups 2>/dev/null || true
sudo docker volume rm -f mistborn_production_traefik 2>/dev/null || true

# generate production .env file
if [ ! -d ./.envs/.production ]; then
    ./scripts/subinstallers/gen_prod_env.sh "$MISTBORN_DEFAULT_PASSWORD"
fi

# unattended upgrades
sudo cp ./scripts/conf/20auto-upgrades /etc/apt/apt.conf.d/
sudo cp ./scripts/conf/50unattended-upgrades /etc/apt/apt.conf.d/

sudo systemctl stop unattended-upgrades
sudo systemctl daemon-reload
sudo systemctl restart unattended-upgrades

# setup Mistborn services

# install and start base services
# default interface
sudo cp ./scripts/services/Mistborn* /etc/systemd/system/
sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/User=root/User=$USER/"
#sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/ root:root / $USER:$USER /"
sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/DIFACE/$iface/"

#if [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
#    # remove systemd-resolved lines
#    sudo sed -i '/.*systemd-resolved/d' /etc/systemd/system/Mistborn-base.service
#fi

# setup local volumes for pihole
sudo mkdir -p ../mistborn_volumes/
sudo chown -R root:root ../mistborn_volumes/
sudo mkdir -p ../mistborn_volumes/base/pihole/etc-pihole
sudo mkdir -p ../mistborn_volumes/base/pihole/etc-dnsmasqd
sudo mkdir -p ../mistborn_volumes/extra

# Traefik final setup (cockpit)
cp ./compose/production/traefik/traefik.toml.template ./compose/production/traefik/traefik.toml
# setup tls certs 
source ./scripts/subinstallers/openssl.sh
sudo rm -rf ../mistborn_volumes/base/tls
sudo mv ./tls ../mistborn_volumes/base/

# Download docker images while DNS is operable
sudo docker-compose -f base.yml pull || true
sudo docker-compose -f base.yml build

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
sudo sed -i "s/#name_servers.*/name_servers=$IPV4_PUBLIC/" /etc/resolvconf.conf
sudo sed -i "s/name_servers.*/name_servers=$IPV4_PUBLIC/" /etc/resolvconf.conf
#sudo sed -i "s/#name_servers.*/name_servers=127.0.0.1/" /etc/resolvconf.conf
sudo resolvconf -u 1>/dev/null 2>&1

echo "backup up original volumes folder"
sudo mkdir -p ../mistborn_backup
sudo tar -czf ../mistborn_backup/mistborn_volumes_backup.tar.gz ../mistborn_volumes 1>/dev/null 2>&1

# start base service
sudo systemctl enable Mistborn-base.service
sudo systemctl start Mistborn-base.service
popd

figlet "Mistborn Installed"
echo "Watch Mistborn start: sudo journalctl -xfu Mistborn-base"
echo "Retrieve Wireguard default config for admin: sudo docker-compose -f /opt/mistborn/base.yml run --rm django python manage.py getconf admin default"
