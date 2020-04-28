# Mistborn
A secure platform for easily standing up and managing your own cloud services: including firewall, ad-blocking, and Wireguard VPN access

# Table of Contents
[[_TOC_]]

# What is Mistborn
The term [Mistborn](http://www.brandonsanderson.com/the-mistborn-saga-the-original-trilogy) is inspired by a type of powerful Allomancer in Brandon Sanderson's Cosmere.

Mistborn started as a passion project for a husband and father protecting his family. Certain family members insisted on connecting their devices to free public WiFi networks. We needed a way to secure all family devices with a solid VPN (Wireguard). Once we had that we wanted to control DNS to block ads to all devices and block malicious websites across all family devices. Then we wanted chat, file-sharing, and webchat services that we could use for ourselves without entrusting our data to some big tech company. And then... home automation. I know I'll be adding more services so I made that easy to do.

Ideal for teams who:
- hate internet ads
- need to be protected from malicious internet domains
- need to collaborate securely
- want to retain sole ownership of their data
- want to easily grant and revoke access to people and devices via a simple web interface
- want secure internet access wherever they are
- want to limit or stop data collecting services

Mistborn depends on these core open source technologies:
- [Docker](https://www.docker.com/why-docker): containerization
- [Wireguard](https://www.wireguard.com): secure VPN access
- [SSH](https://www.openssh.com): secure remote management

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

# Quickstart
Tested Operating Systems (in order of thoroughness):
- Ubuntu 18.04 LTS
- Ubuntu 20.04 LTS
- Debian 10 (Buster)
- Raspbian Buster

Recommended System Specifications:

| Use Case               | Description                                                                   | RAM   | Hard Disk |
|------------------------|-------------------------------------------------------------------------------|-------|-----------|
| Bare bones             | Wireguard, Pihole (no Cockpit, no extra services)                             | 1 GB  | 10 GB     |
| Default                | Bare bones + Cockpit                                                          | 2 GB  | 10 GB     |
| Low-resource services  | Default + Bitwarden, Tor, Syncthing                                           | 3 GB  | 15 GB     |
| High-resource services | Default + Jitsi, Nextcloud, Jellyfin, Rocket.Chat, Home Assistant, OnlyOffice | 4 GB+ | 25 GB+    |

Starting from base installation
```
git clone https://gitlab.com/cyber5k/mistborn.git
sudo bash ./mistborn/scripts/install.sh
```

Get default admin Wireguard profile
*wait 1 minute after "Mistborn Installed" message*
```
sudo mistborn-cli getconf 
```

Connect via Wireguard then visit `http://home.mistborn`

For more information, see the `Installation` section below.

# Network Diagram
![Mistborn Network Diagram](https://gitlab.com/cyber5k/public/-/raw/master/graphics/mistborn_network.png)

Mistborn protects your data in a variety of ways:
- All of your devices are protected wherever they go with the Wireguard VPN protocol
- The Mistborn firewall blocks unsolicited incoming internet packets
- Pi-hole running on Mistborn blocks outgoing internet requests to configurable blocked domains (ads, malicious/phishing domains, etc.) 

# Coppercloud
Pihole provides a way to block outgoing DNS requests for given lists of blocked domains. Coppercloud provides a way to block outgoing network calls of all types to given lists of IP addresses (IPv4 only for now). This is especially useful for blocking outgoing telemetry (data and state sharing) to owners of software running on all of your devices.

![Mistborn Coppercloud IP Filtering](https://gitlab.com/cyber5k/public/-/raw/master/graphics/home.mistborn_coppercloud_.png)

This example shows Coppercloud blocking a list of Microsoft IP addresses on a network with Windows 10 clients.

# Gateways
We were getting frustrated at being forced to choose between being connected to our VPN and using streaming services that we have paid for.

![Netflix blocked](https://gitlab.com/cyber5k/public/-/raw/master/graphics/netflix_blocked.png)

*Netflix blocking my connections that it sees coming from a DigitalOcean droplet*

In Mistborn, Gateways are upstream from the VPN server so connections to third-party services (e.g. Netflix, Hulu, etc.) will appear to be coming from the public IP address of the Gateway. I setup a Gateway at home (Mistborn on DigitalOcean) then all Wireguard profiles created with this Gateway will appear to be coming from my house and are not blocked. No port-forwarding required (assuming Mistborn is publicly accessible).

![Mistborn Gateway Diagram](https://gitlab.com/cyber5k/public/-/raw/master/graphics/gateway_network.png)

The Gateway adds an extra network hop. DNS is still resolved in Mistborn so pihole is still blocking ads.

# Installation
Mistborn is regularly tested on Ubuntu 18.04 LTS (DigitalOcean droplet with 2 GB RAM). It has also been successfully used on Debian Buster and Raspbian Buster systems (though not regularly tested). Additionally tested on Ubuntu 20.04 LTS.

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
When Mistborn-base starts up it will create volumes, initialize the PostgreSQL database, start pihole, run Django migrations and then check to see if a Mistborn superuser named `admin` exists yet. If not, it will create the superuser `admin` along with an accompanying default Wireguard configuration file and start the Wireguard service. You can watch all of this happen with:
```
sudo journalctl -xfu Mistborn-base
```

The default Wireguard configuration file for `admin` may be obtained via:
```
sudo mistborn-cli getconf 
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
[Install wireguard](https://www.wireguard.com/install/) on your computer. If you get a `resolvconf: command not found` error when starting Wireguard then install openresolv: `sudo apt-get install -y openresolv`
- Copy the text of the default admin Wireguard config to `/etc/wireguard/wg_admin.conf` on your computer
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

# Default Credentials
These are the default credentials to use in the services you choose to use:

| Service | Username | Password |
| ------- | -------- | -------- |
| Pihole |  | {{default mistborn password}} |
| Cockpit | cockpit | {{default mistborn password}} |
| Nextcloud | mistborn | {{default mistborn password}} |

# Gateway Setup
Mistborn will generate the Wireguard configuration script for the Gateway. From a base Ubuntu/Debian/Raspbian operating system the following packages are recommended to be installed beforehand:

## Gateway Requirements
- Wireguard (you can consult the Mistborn Wireguard installer: `mistborn/scripts/subinstallers/wireguard.sh`)
- Openresolv (a Wireguard dependency that is also installed via the Mistborn Wireguard installer)
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

# FAQ
Frequently Asked Questions

## Where is My Data?

The Docker services mount volumes located in:
```
/opt/mistborn_volumes
```

The core Mistborn services have volumes mounted in `/opt/mistborn_volumes/base`. These should not be modified. The extra services' volumes are mounted in:
```
/opt/mistborn_volumes/extra
```

Your data from Nextcloud, Syncthing, Bitwarden, etc. will be located there.

## How do I SSH into Mistborn?
If Mistborn is installed via SSH then an iptables rule is added allowing external SSH connections from the same source IP address only. If Mistborn was installed locally then no external SSH is permitted.

SSH is permitted from any device connected to Mistborn by Wireguard.

Password authentication in enabled. Mistborn disables password authentication for root. Fail2ban blocks IPs with excessive failed login attempts.

You can SSH using the Mistborn domain when connected by Wireguard:
```
ssh user@home.mistborn
```

# Troubleshooting

Once you're connected to Wireguard you should see .mistborn domains and the internet should work as expected. Be sure to use http (http://home.mistborn). Wireguard is the encrypted channel so there's usually no need to bother with TLS certs (WebRTC functionality and some mobile apps require TLS so it is available). Here are some things to check if you have issues:

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

## Troubleshooting Docker
Instead of defaulting to a system DNS server, Docker will try to use a public DNS server (e.g. 8.8.8.8). If you're having issues pulling or building Docker containers with "failure to connect" errors, this is the likely problem. You can manually set the DNS server Docker should use with the `DOCKER_OPTS` field in `/etc/default/docker`. Example:
```
DOCKER_OPTS="--dns 192.168.50.1 --dns 1.1.1.1"
```

Be sure to restart Docker afterward:
```
sudo systemctl restart docker
```

## Troubleshooting Upgrade from Ubuntu 18.04 to 20.04
New installations of 18.04 and 20.04 after 25 April 2020 don't seem to be having issues. If you installed Mistborn on Ubuntu 18.04 prior to 25 April 2020 and then upgrade to 20.04 you may have one minor issue described below.

Owing to changes in docker NAT rules and container DNS resolution, some Wireguard client configurations generated with Mistborn before 25 April 2020 (be sure to update Mistborn) may experience issues after upgrading to Ubuntu 20.04 LTS. Symptoms: can ping but can't resolve DNS.

Solution: Edit the Wireguard client config and set the DNS directive as follows:
```
DNS = 10.2.3.1
```
Close the config and restart the client Wireguard process.

# Technical and Security Insights
These are some notes regarding the technical design and implementations of Mistborn. Feel free to contact me for additional details.

## Attack Surface
- **Wireguard**: Wireguard is the only way in to Mistborn. When new Wireguard profiles are generated they are attached to a random UDP port. Wireguard does not respond to unauthenticated traffic. External probes on the active Wireguard listening ports are not logged and do not appear on the Metrics page.
- **SSH**: If Mistborn is installed over SSH (most common) then an iptables rule is added allowing future SSH connections from the same source IP address. All other external SSH is blocked. Internal SSH (over the Wireguard tunnels) is allowed. Password authentication is allowed. The SSH key for the `mistborn` user is only accepted from internal source IP addresses. Fail2ban is also installed.
- **Traefik**: Iptables closes web ports (TCP 80 and 443) from external access and additonally all web interfaces are behind the Traefik reverse-proxy. All web requests (e.g. home.mistborn) must be resolved by Mistborn DNS (Pihole/dnsmasq) and originate from a Wireguard tunnel.
- **Docker**: When Docker exposes a port it creates a PREROUTING rule in the NAT table to catch eligible network requests. This means that even if your INPUT chain policy is DROP, your docker containers with exposed ports can receive and respond to traffic. Whenever Mistborn brings up a docker container with an exposed port it creates an iptables rule to block external traffic to that service. 

## Firewall
- **IPtables**: Iptables rules and chains are manipulated directly. If UFW is present it is disabled. IPtables-persistent is used to save a simple set of secure default rules (most importantly setting the INPUT and FORWARD policies to DROP and allowing ESTABLISHED and RELATED traffic) that will be effective immediately upon system startup. Additional rules and chains are created by Docker on startup. Mistborn also creates some iptables chains during installation that are saved in the persistent rules. Mistborn iptables chains and rules are designed to work with Docker's with logic that is easy to follow. A power cycle will always result in a working state.
- **PostUp/PostDown**: Wireguard configuration files on Mistborn include PostUp and PostDown directives that set routes and iptables rules for each Wireguard client individually.
- **Wireguard**: There is a one-to-one mapping between each Wireguard client and server instance listening on Mistborn. By design Wireguard clients cannot talk directly to each other but can use shared services and resources on Mistborn (e.g. Syncthing, Nextcloud, Jitisi, etc.)
- **Metrics**: In addition to the iptables INPUT policy set to DROP, an iptables chain exists that logs the packet meta data before dropping it. Mistborn redirects packets that will be dropped to this chain instead. A summary of the data about these dropped packets (unsolicited network traffic) can be found on the Metrics page.
- **Coppercloud**: Coppercloud works by populating ipsets with the ipset module in iptables to DROP (blacklist) or ACCEPT (whitelist) a given set of IP addresses. Upon system startup a celery task will compile the IP addresses, create the ipsets, and iptables rules.

## Additonal Notes
- Interface names are not hardcoded anywhere in Mistborn. Two commands that are used in different circumstances to determine the default network interface and the interface that would route a public IP address are: `ip -o -4 route show to default` and `ip -o -4 route get 1.1.1.1`.
- The "Update" button will pull updated Docker images for mistborn, postgresql, redis, pihole, and dnscrypt. Those services will then be restarted.
- The generated TLS certificate has an RSA modulus of 4096 bits, is signed with SHA-256, and is good for 10 years. The nanny at Apple has decided to restrict the kinds of certificates iOS users may choose to manually trust and so you may have issues with TLS on an Apple device for now.
- Outbound UDP on port 53 is blocked. All DNS requests should be handled by the dnscrypt_proxy service and if any client, service, etc. tries to circumvent that it is blocked.

# Roadmap
Many features and refinements are in the works at various stages including:

- Option to upload metrics information to Cyber5K to refine each Mistborn instance's firewall
- Option to email default admin Wireguard config file
- Adding more extra services (e.g. Gitlab, Game Servers, etc.)
- Cyber5K marketplace to share Gateway access (to fixed IP addresses or domains, and for a fixed amount of time)
- Mistborn managing wireless interfaces for local access points (stripped down RaspAP)
- Optional periodic backup of local Mistborn config files and credentials to Cyber5K
- Internal network scan tool and feedback
- Anomaly detection in network traffic

# Contact

Contact me at [steven@cyber5k.com](mailto:steven@cyber5k.com)

# Support

Please consider supporting the project via:
- [Paypal.me](https://paypal.me/cyber5k)
- [Patreon](https://www.patreon.com/cyber5k)
