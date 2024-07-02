#!/bin/bash
# File: wifi_enable.sh
# Purpose: Creates and enables a wifi connection on Fedora 40
# Usage:
#   1. Populate ./.wifi_config with env var values
#   2. Create ./.wificreds and populate with wifi password (only the password)
#   3. Run ./wifi_enable.sh
#############################################################################

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "$SCRIPT_DIR/.wifi_config"

# No creds? Bail.
if [ ! -f "$SCRIPT_DIR/.wificreds" ]; then
  echo "Error: $SCRIPT_DIR/.wificreds file not found - exiting (no changes made)."
  exit 1
fi

export WIFI_PSK=$(cat "$SCRIPT_DIR/.wificreds")

# Add the wireless connection
nmcli connection add type wifi ifname $INT_NAME con-name $CONN_NAME ssid $SSID

# Modify the connection to set the security type and password
nmcli connection modify $CONN_NAME wifi-sec.key-mgmt wpa-psk
nmcli connection modify $CONN_NAME wifi-sec.psk "$WIFI_PSK"

# Fedora 40 uses dynamic MAC addresses for wifi connections, so we set the
# MAC address for the connection to the MAC we've reserved on the DHCP server.
nmcli connection modify $CONN_NAME 802-11-wireless.cloned-mac-address $MAC_ADDR

# Bring up the connection
nmcli connection up $CONN_NAME

# Display the connection settings
nmcli connection show
