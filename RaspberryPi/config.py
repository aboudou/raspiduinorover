import os

"""
" Edit below this line to fit your needs
"""

# Interface to LISTEN ("0.0.0.0" for all interfaces)
IFACE = "0.0.0.0"

# Network port to LISTEN
PORT = 8000

# I2C bus to use : 0 for older Raspberry Pi model B 256MB, 1 for others
I2CBUS = 1

# I2C address of the slave Arduino
ADDRESS = 0x42

# Get path of config file
CONFIG_PATH = os.path.dirname(os.path.realpath(__file__))
# Streaming start script
STREAM_START = [CONFIG_PATH + "/bin/stream.sh", "start"]
# Streaming stop script
STREAM_STOP = [CONFIG_PATH + "/bin/stream.sh", "stop"]

# WLAN adapter (default "wlanO", empty if you don't want / need to get
#   signal strength).
WLAN_ADAPTER = "wlan0"
