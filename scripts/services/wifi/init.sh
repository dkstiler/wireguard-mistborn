#!/bin/bash

# Colors
MAGENTA='\e[0;35m'
RED='\e[0;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

# Check that the interface exists and its not in use. Returns iface phy
iface_check (){
    IFACE="$1"
    
    # Check that the requested iface is available
    if ! [ -e /sys/class/net/"$IFACE" ]
    then
        echo -e "${RED}[ERROR]${NC} The interface provided does not exist. Exiting..."
        exit 1
    fi
   
    # Check that the given interface is not used by the host as the default route
    if [[ $(ip r | grep default | cut -d " " -f5) == "$IFACE" ]]
    then
        echo -e "${BLUE}[INFO]${NC} The selected interface is configured as the default route, if you use it you will lose internet connectivity"
        exit 1;
	fi

    # Find the physical interface for the given wireless interface
    PHY=$(cat /sys/class/net/"$IFACE"/phy80211/name)
    echo $PHY
}

hostapd_setup() {
    ### Check if hostapd is running in the host
    hostapd_pid=$(pgrep hostapd)
    if [ ! "$hostapd_pid" == "" ] 
    then
       echo -e "${BLUE}[INFO]${NC} hostapd service is already running in the system, make sure you use a different wireless interface..."
       #kill -9 "$hostapd_pid"
    fi

    # Unblock wifi and bring the wireless interface up
    echo -e "${BLUE}[INFO]${NC} Unblocking wifi and setting ${IFACE} up"
    rfkill unblock wifi
    ip link set "$IFACE" up

    # Check if a wlan config file exists, else take wlan parameters by default
    if [ -e "$PATHSCRIPT"/"$CONF_FILE" ]
    then
        echo -e "${BLUE}[INFO]${NC} Found WLAN config file"
	    # Parse the wlan config file
		IFS="="
		while read -r name value
		do
                    case $name in
                        ''|\#* ) continue;; # Skip blank lines and lines starting with #
                        "SSID" )
                            SSID=${value//\"/}
                            echo -e "${BLUE}"[INFO]"${NC}" SSID: "${MAGENTA}""$SSID""${NC}";;
                        "PASSPHRASE" )
                            PASSPHRASE=${value//\"/};;
                        "HW_MODE" )
                            HW_MODE=${value//\"/};;
                        "CHANNEL" )
                            CHANNEL=${value//\"/};;
                        * )
                            echo Parameter "$name" in "$PATHSCRIPT"/"$CONF_FILE" not recognized
		    esac
		done < "$PATHSCRIPT"/"$CONF_FILE"
    else
        echo -e "${BLUE}[INFO]${NC} WLAN config file not found. Setting default WLAN parameters"
        echo -e "${BLUE}"[INFO]"${NC}" SSID: "${MAGENTA}""$SSID""${NC}"
    fi

}