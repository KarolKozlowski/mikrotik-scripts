/ip firewall mangle
add action=mark-connection chain=postrouting comment="mark guest connections" connection-state=new new-connection-mark=guest \
    out-interface-list=WAN src-address=172.16.90.0/24
add action=mark-connection chain=postrouting comment="mark iot connections" connection-state=new new-connection-mark=iot \
    out-interface-list=WAN src-address=172.16.80.0/24
add action=mark-packet chain=forward comment="mark local packets" dst-address-list=local new-packet-mark=local src-address-list=\
    local
add action=mark-packet chain=prerouting comment="mark guest-outgoing" connection-mark=guest in-interface-list=LAN \
    new-packet-mark=guest-outgoing passthrough=no
add action=mark-packet chain=prerouting comment="mark iot-outgoing" connection-mark=iot in-interface-list=LAN new-packet-mark=\
    iot-outgoing passthrough=no
add action=mark-packet chain=prerouting comment="mark guest-incoming" connection-mark=guest in-interface-list=WAN \
    new-packet-mark=guest-incoming passthrough=no
add action=mark-packet chain=prerouting comment="mark iot-incoming" connection-mark=iot in-interface-list=WAN new-packet-mark=\
    iot-incoming passthrough=no


/queue tree
add name=bestgo-queue parent=ether.bestgo
add name=bestgo-no-mark packet-mark=no-mark parent=bestgo-queue priority=5
add name=bridge-queue parent=bridge
add name=neostrada-queue parent=pppoe-neostrada
add max-limit=25M name=neostrada-guest-outgoing packet-mark=guest-outgoing parent=neostrada-queue
add max-limit=10M name=bestgo-iot-outgoing packet-mark=iot-outgoing parent=bestgo-queue
add max-limit=10M name=bridge-iot-incoming packet-mark=iot-incoming parent=bridge-queue
add name=neostrada-no-mark packet-mark=no-mark parent=neostrada-queue priority=5
add name=bridge-no-mark packet-mark=no-mark parent=bridge-queue priority=5
add name=bridge-local packet-mark=local parent=bridge-queue priority=3
add max-limit=25M name=bridge-guest-incoming packet-mark=guest-incoming parent=bridge-queue
add max-limit=25M name=bestgo-guest-outgoing packet-mark=guest-outgoing parent=bestgo-queue
add max-limit=10M name=neostrada-iot-outgoing packet-mark=iot-outgoing parent=neostrada-queue
