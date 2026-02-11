#!/bin/sh
#
export MIKROTIK_PUBLIC_IP=195.136.68.11
export MIKROTIK_DEST_IP=172.16.1.65

# 7777/tcp used for server control VULNERABLE
# https://wiki.starrupture-utilities.com/en/dedicated-server/configuration

# ./gen-nat.py --ports '7777/tcp,7777/udp,27015/udp' --app 'StarRupture'
./gen-nat.py --ports '7777/tcp,7777/udp,27015/udp' --app 'StarRupture'
