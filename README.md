# Mistborn
A platform for easily managing your cloud server and Wireguard access

# Table of Contents
[[_TOC_]]

# What is Mistborn
The term [Mistborn](http://www.brandonsanderson.com/the-mistborn-saga-the-original-trilogy) comes from a type of powerful Allomancer in Brandon Sanderson's Cosmere.

Mistborn started as a passion project for a husband and father protecting his family. Certain family members insisted on connecting their devices to free WiFi networks. We needed a way to secure all family devices with a solid VPN (Wireguard). Once we had that we wanted to control DNS to block ads to all devices and block malicious and pornographic websites across all family devices. Then we wanted chat, file-sharing, and webchat services that we could use for ourselves without entrusting our data to some big tech company. And then... home automation. I know I'll be adding services as I go so I made that easy to do.

Mistborn depends on these open source technologies:
- [Docker](https://www.docker.com/why-docker): containerization
- [Wireguard](https://www.wireguard.com): secure VPN access
- [SSH](https://www.openssh.com): secure password-less remote management

These tools are not vital to Mistborn itself but are integrated to enhance security, ease, and features:
- [iptables](https://www.netfilter.org): The powerful Linux netfilter firewall tool
- [cockpit](https://cockpit-project.org): A Graphical User Interface for system management, including container management
- [Pi-hole](https://pi-hole.net): A DNS server for network-wide ad blocking, etc
- [DNScrypt](https://www.dnscrypt.org): prevents DNS spoofing via cryptographic signatures to verify that responses originate from the chosen DNS resolver and haven't been tampered
- [Traefik](https://docs.traefik.io): A modern, efficient reverse-proxy

Within Mistborn is a panel to enable and manage these free extra services (off by default), locally hosted in Docker containers:
- [Home Assistant](https://www.home-assistant.io): Open source home automation that puts local control and privacy first
- [Nextcloud](https://nextcloud.com): Nextcloud offers the industry-leading, on-premises content collaboration platform. It combines the convenience and ease of use of consumer-grade solutions like Dropbox and Google Drive with the security, privacy and control business needs.
- [BitWarden](https://bitwarden.com): Password manager. The easiest and safest way for individuals, teams, and business organizations to store, share, and sync sensitive data.
- [Syncthing](https://syncthing.net): Syncthing is a continuous file synchronization program. It synchronizes files between two or more computers in real time, safely protected from prying eyes.
- [OnlyOffice](https://www.onlyoffice.com): Cloud office suite. ONLYOFFICE provides you with the most secure way to create, edit and collaborate on business documents online.
- [Rocket.Chat](https://rocket.chat): Free, Open Source, Enterprise Team Chat.
- [Jellyfin](https://jellyfin.org): The Free Media Software System.
- [Tor](https://www.torproject.org): The Onion Router. One tool in the arsenal of online security and privacy.
- [Jitsi](https://jitsi.org): Multi-platform open-source video conferencing

# Network Diagram
![Mistborn Network Diagram](https://gitlab.com/cyber5k/public/-/raw/master/graphics/mistborn_network.png)

Mistborn protects your data in a variety of ways:
- All of your devices are protected wherever they go with the Wireguard VPN protocol
- The Mistborn firewall blocks unsolicited incoming internet packets
- Pi-hole running on Mistborn blocks outgoing internet requests to configurable blocked domains (ads, malicious/phishing domains, etc.) 

# Gateways
I was getting frustrated at being forced to choose between being connected to my VPN and using streaming services that I have paid for.

![Netflix blocked](https://gitlab.com/cyber5k/public/-/raw/master/graphics/netflix_blocked.png)

*Netflix blocking my connections that it sees coming from a DigitalOcean droplet*

In Mistborn, Gateways are upstream from the VPN server so connections to third-party services (e.g. Netflix, Hulu, etc.) will appear to be coming from the public IP address of the Gateway. I setup a Gateway at home, then all VPN profiles created with this Gateway will apear to be coming from my house and are not blocked. No port-forwarding required (assuming Mistborn is publicly accessible).

![Mistborn Gateway Diagram](https://gitlab.com/cyber5k/public/-/raw/master/graphics/gateway_network.png)

The Gateway adds an extra network hop. DNS is still resolved in Mistborn so pihole is still blocking ads.

# Installation
Mistborn is regularly tested on Ubuntu 18.04 LTS (DigitalOcean droplet with 2 GB RAM). It has also been successfully used on Debian Buster and Raspbian Buster systems (though not regularly tested).

Clone the git repository and run the install script:
```
git clone https://gitlab.com/cyber5k/mistborn.git
sudo bash ./mistborn/scripts/install.sh
```

Running `install.sh` will do the following:
- create a `mistborn` system user
- clone the mistborn repo to `/opt/mistborn`
- setup iptables and ip6tables rules and chains
- install iptables-persistent
- install Docker
- install OpenSSH
- install Wireguard
- install Cockpit
- create a `cockpit` system user
- configure unattended-upgrades
- generate a self-signed TLS certificate/key (WebRTC functionality requires TLS)
- create and populate traefik.toml
- create `/opt/mistborn_volumes` and setup folders for services that will be mounted within
- backup original contents of `/opt/mistborn_volumes` in `/opt/mistborn_backup`
- Pull docker images for base.yml
- Build docker images for base.yml
- Disable competing DNS services (systemd-resolved and dnsmasq)
- copy Mistborn systemd service files to `/etc/systemd/system`
- start and enable Mistborn-base

# Post-Installation
When Mistborn-base starts up it will create volumes, initialize the PostgreSQL database, start pihole, run Django migrations and then check to see if a Mistborn superuser named `admin` exists yet. If not, it will create the superuser along with an accompanying Wireguard configuration file and start the Wireguard service. You can watch all of this happen with:
```
sudo journalctl -xfu Mistborn-base
```

The client Wireguard configuration file may be obtained via:
```
sudo docker-compose -f /opt/mistborn/base.yml run --rm django python manage.py getconf admin default
```
Please notice that the following lines are **NOT** part of the Wireguard config:
```
Starting mistborn_production_postgres ... done
Starting mistborn_production_redis    ... done
PostgreSQL is available
```

The Wireguard config will look like this:
```
# "10.15.91.2" - WireGuard Client Profile
[Interface]
Address = 10.15.91.2/32
# The use of DNS below effectively expands to:
#   PostUp = echo nameserver 10.15.91.1 | resolvconf -a tun.%i -m 0 -x
#   PostDown = resolvconf -d tun.%i
# If the use of resolvconf is not desirable, simply remove the DNS line
# and use a variant of the PostUp/PostDown lines above.
# The IP address of the DNS server that is available via the encrypted
# WireGuard interface is 10.15.91.1.
DNS = 10.15.91.1
PrivateKey = cPPflVGsxVFw2/lMmhiFTXMmH345bGqoqArD/NgjiXU=

[Peer]
PublicKey = DfIV1urYZXqXKiU4rOSfO0Iu589pEO+59dHV5w5N0mU=
PresharedKey = Z1SO5NuAnZ7JhzVCuUnYOQLWOQYmMoqG0pG1SNXUlh0=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = <Mistborn public IP address>:39207
```

## Login via Wireguard
[Install wireguard](https://www.wireguard.com/install/) on your computer.
- Copy the admin Wireguard config to `/etc/wireguard/wg_admin.conf`
- Run `sudo systemctl start wg-quick@wg_admin`
- Run `sudo systemctl enable wg-quick@wg_admin`
- Open your browser and go to "http://home.mistborn"
- Browse your Mistborn system!
**Note:** The home.mistborn server takes a minute to come up after Mistborn is up (collectstatic on all that frontend JavaScript and CSS)

## Wireguard Management
Mistborn users can be added (non-privileged or superuser) and removed by superusers. Multiple Wireguard profiles can be created for each user. A non-privileged user can create profiles for themselves.
![Mistborn Wireguard](https://gitlab.com/cyber5k/public/-/raw/master/graphics/home.mistborn_wireguard_.png)*Wireguard Management in Mistborn*

## Extra Services
Mistborn makes extra services available.
![Mistborn Extra Services](https://gitlab.com/cyber5k/public/-/raw/master/graphics/home.mistborn_extra_.png)*Mistborn Extra Services Available*

## Mistborn Firewall Metrics
Mistborn functions as a network firewall and provides metrics on blocked probes from the internet.
![Mistborn Metrics](https://gitlab.com/cyber5k/public/-/raw/master/graphics/home.mistborn_metrics.png)*Mistborn Firewall Metrics*

# Mistborn Subdomains
Mistborn uses the following domains (that can be reached by all Wireguard clients):

| Service | Domain | Default Status |
| ------- | ------ | -------------- |
| **Home** | home.mistborn | On |
| **Pihole** | pihole.mistborn | On |
| **Cockpit** | cockpit.mistborn | On |
| Nextcloud | nextcloud.mistborn | Off |
| Rocket.Chat | chat.mistborn | Off |
| Home Assistant | homeassistant.mistborn | Off |
| Bitwarden | bitwarden.mistborn | Off |
| Jellyfin | jellyfin.mistborn | Off |
| Syncthing | syncthing.mistborn | Off |
| OnlyOffice | onlyoffice.mistborn | Off |
| Jitsi | jitsi.mistborn | Off |

# Gateway Setup
Mistborn will generate the Wireguard configuration script for the Gateway. From a base Ubuntu/Debian/Raspbian operating system the following packages are recommended to be installed beforehand:

## Gateway Requirements
- Wireguard (you can run the Mistborn Wireguard installer: `sudo bash /opt/mistborn/scripts/subinstallers/wireguard.sh`)
- Openresolv (a Wireguard dependency that is installed via the Mistborn Wireguard installer)
- Fail2ban

## Install Gateway Wireguard config file
On Mistborn:
- Click `View Config` on the Gateways tab in Mistborn
- Highlight the config
- Copy (Ctrl-C)

On Gateway:
- Paste the config to `/etc/wireguard/gateway.conf`
- Run `sudo systemctl start wg-quick@gateway`
- Run `sudo systemctl enable wg-quick@gateway`

# Troubleshooting

Once you're connected to Wireguard you should see .mistborn domains and the internet should work as expected. Be sure to use http (http://home.mistborn). Wireguard is the encrypted channel so we're not bothering with TLS certs. Here are some things to check if you have issues:

See if any docker containers are stopped:
```
sudo docker container ls -a
```

Check the running log for Mistborn-base:
```
sudo journalctl -xfu Mistborn-base
```

Mistborn-base is a systemd process and at any time restarting it should get you to a working state:
```
sudo systemctl restart Mistborn-base
```

The Wireguard processes run independently of Mistborn and will still be up if Mistborn is down. You can check running Wireguard interfaces with:
```
sudo wg show
```
Note the Mistborn naming convention for Wireguard interfaces on the server is wg<listening port>. So if the particular Wireguard process is listening on UDP port 56392 then the interface will be named wg56392 and the config will be in `/etc/wireguard/wg56392.conf`

The `dev/` folder contains a script for completing a hard reset: destroying and rebuilding the system from the original backup:
```
sudo ./dev/rebuild.sh
```

# Contact

Contact me at [steven@cyber5k.com](mailto:steven@cyber5k.com)

# Support

Please consider supporting the project via:
- [Patreon](https://www.patreon.com/cyber5k)
