#!/bin/sh
#
export MIKROTIK_PUBLIC_IP=195.136.68.11
export MIKROTIK_DEST_IP=172.16.1.65

./gen-nat.py --ports '7777/udp,27015/udp' --app 'StarRupture'
