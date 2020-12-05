# Mistborn
A secure platform for easily standing up and managing your own cloud services: including firewall, ad-blocking, and multi-factor Wireguard VPN access

![Mistborn Wireguard](https://gitlab.com/cyber5k/public/-/raw/master/graphics/home.mistborn_wireguard_.png)*Wireguard Management in Mistborn*

As featured in [Linux Magazine](https://www.linux-magazine.com/Issues/2020/240/Mistborn/(language)/eng-US) (Linux Pro Magazine in North America) in November 2020

![Mistborn Featured in Linux Magazine](https://gitlab.com/cyber5k/public/-/raw/master/graphics/linux-magazine-cover-nov-2020.jpg "Mistborn featured in Linux Magazine November 2020")

# Table of Contents
[[_TOC_]]

# What is Mistborn
The term [Mistborn](http://www.brandonsanderson.com/the-mistborn-saga-the-original-trilogy) is inspired by a type of powerful Allomancer in Brandon Sanderson's Cosmere.

Mistborn started as a passion project for a husband and father protecting his family. Certain family members insisted on connecting their devices to free public WiFi networks. We needed a way to secure all family devices with a solid VPN (Wireguard). Once we had that we wanted to control DNS to block ads to all devices and block malicious websites across all family devices. Then we wanted chat, file-sharing, and webchat services that we could use for ourselves without entrusting our data to some big tech company. And then... home automation. I know I'll be adding more services so I made that easy to do.

Ideal for teams who:
- hate internet ads
- need to be protected from malicious internet domains
- need to collaborate securely
- need multi-factor authentication for Wireguard
- want to retain sole ownership of their data
- want to easily grant and revoke access to people and devices via a simple web interface
- want secure internet access wherever they are
- want to limit or stop data collecting services
- want to prevent being detected/blocked for using a proxy or VPN service

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
- Ubuntu 20.04 LTS
- Ubuntu 18.04 LTS
- Debian 10 (Buster)
- Raspberry Pi OS (formerly Raspbian) Buster

**Note:** Install operating system updates and restart. Raspberry Pi OS particularly needs to be restarted after kernel updates (kernel modules for the currently running kernel may be missing).

Tested Browsers:
- Firefox

The default tests are run on DigitalOcean Droplets: 2GB RAM, 1 CPU, 50GB hard disk.

The Mistborn docker images exist for these architectures:

| Mistborn Docker Images (hub.docker.com)        | Architectures       |
|------------------------------------------------|---------------------|
| mistborn (django, celery{worker,beat}, flower) | amd64, arm64, arm/v7 |
| dnscrypt-proxy                                 | amd64, arm64, arm/v7 |

Recommended System Specifications:

| Use Case               | Description                                                                   | RAM   | Hard Disk |
|------------------------|-------------------------------------------------------------------------------|-------|-----------|
| Bare bones             | Wireguard, Pihole (no Cockpit, no extra services)                             | 2 GB  | 15 GB     |
| Default                | Bare bones + Cockpit                                                          | 2 GB+ | 15 GB     |
| Low-resource services  | Default + Bitwarden, Tor, Syncthing                                           | 4 GB  | 20 GB     |
| High-resource services | Default + Jitsi, Nextcloud, Jellyfin, Rocket.Chat, Home Assistant, OnlyOffice | 6 GB+ | 25 GB+    |

Starting from base installation
```
git clone https://gitlab.com/cyber5k/mistborn.git
sudo -E bash ./mistborn/scripts/install.sh
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

In Mistborn, Gateways are upstream from the VPN server so connections to third-party services (e.g. Netflix, Hulu, etc.) will appear to be coming from the public IP address of the Gateway. I setup a Gateway at home (Raspberry Pi with `wireguard` and `openresolv` installed) and with our Mistborn on DigitalOcean, all Wireguard profiles created with this Gateway will appear to be coming from my house and are not blocked. No port-forwarding required (assuming Mistborn is publicly accessible).

![Mistborn Gateway Diagram](https://gitlab.com/cyber5k/public/-/raw/master/graphics/gateway_network.png)

The Gateway adds an extra network hop. DNS is still resolved in Mistborn so pihole is still blocking ads.

# Client to client communication
By default direct communication between network clients is blocked. Mistborn clients can all talk to Mistborn and communicate via shared services (Jitsi, Nextcloud, etc). Direct client to client communication can be enabled via the "client-to-client" toggle.

![System Settings](https://gitlab.com/cyber5k/public/-/raw/master/graphics/system_settings_dropdown.png)

# Installation
Mistborn is regularly tested on Ubuntu 20.04 LTS (DigitalOcean droplet with 2 GB RAM). It has also been successfully used on Debian Buster and Raspbian Buster systems (though not regularly tested). Make sure to install OS updates and restart before installing Mistborn (Wireguard installs differently on recent kernels).

Clone the git repository and run the install script:
```
git clone https://gitlab.com/cyber5k/mistborn.git
sudo -E bash ./mistborn/scripts/install.sh
```

Running `install.sh` will do the following:
- create a `mistborn` system user
- clone the mistborn repo to `/opt/mistborn`
- setup iptables and ip6tables rules and chains
- install iptables-persistent
- install Docker
- install OpenSSH
- install Wireguard
- install Cockpit (optional)
- create a `cockpit` system user (if Cockpit is installed)
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

# Non-Interactive Installation
In order to install without interaction some environment variables need to be pre-set. 

## Environment Variables
See the environment variables needed in `./scripts/noninteractive/.install_barebones`

## Example Noninteractive Install
This will perform a noninteractive install with the default environment variables set in `.install_barebones`.
```
git clone https://gitlab.com/cyber5k/mistborn.git
sudo -E bash -c "source ./mistborn/scripts/noninteractive/.install_barebones && ./mistborn/scripts/install.sh"
```

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

# Authentication
There are multiple ways to authenticate and use the system. 

![Mistborn Multi Factor Authentication - Authenticator App Setup](https://gitlab.com/cyber5k/public/-/raw/master/graphics/mfa_qr.png)*Mistborn Multi Factor Authentication - Authenticator App Setup*

## Profile: Wireguard Authentication
Mistborn always authenticates with Wireguard. You must have a valid Wireguard configuration file associated with the correct internal IP address. A classic Mistborn profile (Wireguard Only) will allow you to access the internet and all services hosted by Mistborn once you have connected via Wireguard. Note: individual services may require passwords or additional authentication.

## Profile: Multi Factor Authentication (MFA)
In addition to Wireguard, you may create a Mistborn profile enabling multi-factor authentication (MFA). You must first connect to Mistborn via Wireguard. Then all internet traffic will route you to the Mistborn webserver where you must first setup and thereafter authenticate with an app (Google Authenticator, Authy, etc.). You must go to [http://home.mistborn](http://home.mistborn) to complete the authentication process.

![Mistborn Multi Factor Authentication](https://gitlab.com/cyber5k/public/-/raw/master/graphics/mfa1.png)*Mistborn Multi Factor Authentication Prompt*

### MFA Internet Access
Internet access is blocked via iptables until authentication is completed for an MFA profile. You must go to [http://home.mistborn](http://home.mistborn) to complete the authentication process. Click "Sign Out" to re-block internet access until authentication completes again.

![Mistborn Multi Factor Authentication - Token Prompt](https://gitlab.com/cyber5k/public/-/raw/master/graphics/mfa_token_enter.png)*Mistborn Multi Factor Authentication - Token Prompt*

### MFA Mistborn Service Access - Fixed on 4 December 2020
Mistborn service access is blocked via traefik until Mistborn authentication is complete. You will not be able to access the web pages for pihole, cockpit, or any extra services until authentication is complete for an MFA profile. Attempting to visit one of these pages will produce a "Mistborn: Not authorized" HTTP 403. Click "Sign Out" to re-block access until authentication completes again.

### Notes
- **Sessions**: Traefik checks the authenticated sessions on the server side to determine whether to allow access to the Mistborn service web pages. If an open session exists for your Mistborn IP address then access will be granted. You may close all sessions by clicking "Sign Out" on the Mistborn home page. Expired sessions are regularly cleaned by the Mistborn system (celery periodic task).

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

You can find the credentials sent to the Docker containers in: `/opt/mistborn/.envs/.production/`

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

# Phones and Mobile Devices
All your devices can be connected to Mistborn as Wireguard clients.

First steps:
1. Device: Download the Wireguard app on your device. Links: [Android](https://play.google.com/store/apps/details?id=com.wireguard.android) [Apple](https://apps.apple.com/us/app/wireguard/id1441195209)
1. Mistborn: Create a Wireguard profile for the device.
1. Device: Scan Wireguard client QR code in Wireguard app.
1. Device: Enable Wireguard connection.

All of you device network traffic is now being routed through Wireguard. Ads and malicious sites are blocked by pihole. DNS queries are verified via DNScrypt.

But wait, there's more! You can:
- visit the [Mistborn web interface](http://home.mistborn) through your phone's browser. 
- download the apps for any extra services you have running and connect them to your Mistborn using the Mistborn domains.

## App Links

|                | Android                                                                                            | Apple                                                                              |
|----------------|----------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|
| Nextcloud      | [Nextcloud](https://play.google.com/store/apps/details?id=com.nextcloud.client)                    | [Nextcloud](https://apps.apple.com/us/app/nextcloud/id1125420102)                  |
| Syncthing      | [Syncthing](https://play.google.com/store/apps/details?id=com.nutomic.syncthingandroid)            |                                                                                    |
| Jitsi Meet     | [Jitsi Meet](https://play.google.com/store/apps/details?id=org.jitsi.meet)                         | [Jitsi Meet](https://apps.apple.com/us/app/jitsi-meet/id1165103905)                |
| Bitwarden      | [Bitwarden](https://play.google.com/store/apps/details?id=com.x8bit.bitwarden)                     | [Bitwarden](https://apps.apple.com/us/app/bitwarden-password-manager/id1137397744) |
| Jellyfin       | [Jellyfin](https://play.google.com/store/apps/details?id=org.jellyfin.mobile)                      | [Jellyfin](https://apps.apple.com/us/app/jellyfin-mobile/id1480192618)             |
| Home Assistant | [Home Assistant](https://play.google.com/store/apps/details?id=io.homeassistant.companion.android) |                                                                                    |
| Rocket.Chat    | [Rocket.Chat](https://play.google.com/store/apps/details?id=chat.rocket.android)                   | [Rocket.Chat](https://apps.apple.com/us/app/rocket-chat/id1148741252)              |

## TLS Certificate
Some apps require TLS (HTTPS). All traffic to Mistborn domains already occurs over Wireguard but to keep apps running, a TLS certificate exists for Mistborn and can be imported into your device's trusted credentials in the security settings. This certificate is checked every day and will be re-generated when expiration is less than 30 days away.

The TLS certificate can be found here:
```
/opt/mistborn_volumes/base/tls/cert.crt
```

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

Password authentication in enabled. Fail2ban blocks IPs with excessive failed login attempts.

You can SSH using the Mistborn domain when connected by Wireguard:
```
ssh user@home.mistborn
```

## How do I change the upstream DNSCrypt servers?
The upstream servers used by dnscrypt-proxy are set in:  

`base.yml`:
```
services:
...
  dnscrypt-proxy:
  ...
    environment:
    ...
      - DNSCRYPT_SERVER_NAMES=[...]
```

The available options are here: https://download.dnscrypt.info/dnscrypt-resolvers/v2/public-resolvers.md

# Troubleshooting

Once you're connected to Wireguard you should see .mistborn domains and the internet should work as expected. Be sure to use http (http://home.mistborn). Wireguard is the encrypted channel so there's usually no need to bother with TLS certs (WebRTC functionality and some mobile apps require TLS so it is available). Here are some things to check if you have issues:

Check if you can ping an external IP address:
```
ping 1.1.1.1
```

Check if you can resolve local DNS queries:
```
dig home.mistborn
```

Check if you can resolve external DNS queries:
```
dig cyber5k.com
```

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

## Troubleshooting Wireguard
Ensure that your public IP address in your client profile (e.g. `Endpoint = <Mistborn public IP address>:<random port>`) is actually publicly available (not in 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16) if you are attempting to access Mistborn across the internet.

## Troubleshooting Extra Services
Each extra service has its own systemd process which can be monitored:
```
sudo journalctl -xfu Mistborn-homeassistant
sudo journalctl -xfu Mistborn-bitwarden
sudo journalctl -xfu Mistborn-syncthing
sudo journalctl -xfu Mistborn-jellyfin
sudo journalctl -xfu Mistborn-nextcloud
sudo journalctl -xfu Mistborn-jitsi
sudo journalctl -xfu Mistborn-rocketchat
sudo journalctl -xfu Mistborn-onlyoffice
sudo journalctl -xfu Mistborn-tor
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

## Troubleshooting Raspberry Pi OS (Raspbian)
Be sure to always reboot after updating the kernel. When the kernel is updated the kernel modules are deleted (for the currently running kernel) and you will have issues with any function requiring kernel modules (e.g. `iptables` or `wireguard`).

**Note**: The Raspberry Pi OS 64-bit BETA (versions from May 2020 and prior) have a bug where the os-release info indicates that it is Debian. Mistborn proceeds to install as though it were Debian. Since it's not Debian there are errors.

## Troubleshooting Debian 10
Run updates and restart before installing Mistborn (`sudo apt-get update && sudo apt-get -y dist-upgrade && sudo shutdown -r now`). Some older Linux kernels will prevent newer Wireguard versions from installing.

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
- **Wireguard**: There is a one-to-one mapping between each Wireguard client and server instance listening on Mistborn. By default Wireguard clients cannot talk directly to each other but can use shared services and resources on Mistborn (e.g. Syncthing, Nextcloud, Jitisi, etc). Toggling the "client-to-client" option will enable direct client-to-client communication.
- **Metrics**: In addition to the iptables INPUT policy set to DROP, an iptables chain exists that logs the packet meta data before dropping it. Mistborn redirects packets that will be dropped to this chain instead. A summary of the data about these dropped packets (unsolicited network traffic) can be found on the Metrics page.
- **Coppercloud**: Coppercloud works by populating ipsets with the ipset module in iptables to DROP (blacklist) or ACCEPT (whitelist) a given set of IP addresses. Upon system startup a celery task will compile the IP addresses, create the ipsets, and iptables rules.

## Additonal Notes
- Interface names are not hardcoded anywhere in Mistborn. Two commands that are used in different circumstances to determine the default network interface and the interface that would route a public IP address are: `ip -o -4 route show to default` and `ip -o -4 route get 1.1.1.1`.
- The "Update" button will pull updated Docker images for mistborn, postgresql, redis, pihole, and dnscrypt. Those services will then be restarted.
- The generated TLS certificate has an RSA modulus of 4096 bits, is signed with SHA-256, and is good for 397 days. The certificate is checked daily and will regenerate when expiration is within 30 days.
- Outbound UDP on port 53 is blocked. All DNS requests should be handled by the dnscrypt_proxy service and if any client, service, etc. tries to circumvent that it is blocked.
- Unattended upgrades are set to automatically install operating system security updates.

# Roadmap
Many features and refinements are in the works at various stages including:

- Plugins for Extra Services (enabling third-party development)
- Plugin repository
- Integration with RaspAP to enable managing an Access Point for local network connections
- Internal network scan tool and feedback
- Anomaly detection in network traffic

# Featured In

- [Linux Magazine](https://www.linux-magazine.com/Issues/2020/240/Mistborn/(language)/eng-US) November 2020 (featuring Mistborn version from early May 2020)
- [Awesome Open Source](https://www.youtube.com/watch?v=hekP0_crotw) July 2020 (featuring Mistborn version from early July 2020)

# Follow
You can find recent bugfixes, functional additions, some extra documentation and more at the Cyber5K Patreon page: [https://www.patreon.com/cyber5k](https://www.patreon.com/cyber5k)

# Contact

Contact me at [steven@cyber5k.com](mailto:steven@cyber5k.com)

# Support Mistborn

Please consider supporting the project via:
- [Paypal.me](https://paypal.me/cyber5k)
- [Buy me a drink](https://www.buymeacoffee.com/cyber5k)
- [Patreon](https://www.patreon.com/cyber5k)
