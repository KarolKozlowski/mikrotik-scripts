# interface name to configure queue on
:local queueInterfaceName "uplink-eth"

# mark/comment prefix and sufix
:local prefix "DSCP_"
:local suffix ""

# firewall chanin for marking packages
:local mangleChain "postrouting"

# parent queue name
:local qosParentName ($prefix . $queueInterfaceName)

# human-readable class names
:local qosClasses [:toarray "Network Control,Internetwork Control,Critical,Flash Override,Flash,Immedate,Priority,Routine"]

# add parent queue for the interface
/queue tree add name=$qosParentName parent=$queueInterfaceName priority=1

# iterate over traffic classes
:for qosClass from=0 to=7 do={

    :local qosClassPriority ($qosClass + 1)
    :local qosClassType [:pick $qosClasses $qosClass]
    :local qosClassName ($qosClassPriority . ". " . $qosClassType . " (" . $queueInterfaceName . ")")

    /queue tree add name=$qosClassName parent=$qosParentName priority=$qosClassPriority queue=ethernet-default

    # iterate over traffic priority queues
    :for qosQueue from=0 to=7 do={
        :local qosQueuePriority ($qosQueue + 1)
        :local qosQueueName ($qosClassPriority . "." . $qosQueuePriority . ". " . $qosClassType . " (" . $queueInterfaceName . ")")
        :local dscp (63 - (8 * $qosClass + $qosQueue))
        :local mark ($prefix . $dscp . $suffix)

        # Add firewall rule for marking packets
        /ip firewall mangle add action=mark-packet chain=$mangleChain comment=$mark disabled=no dscp=$dscp new-packet-mark=$mark passthrough=no
        # Add priority queue
        /queue tree add name=$qosQueueName parent=$qosClassName priority=$qosQueuePriority packet-mark=$mark queue=ethernet-default comment=$mark
    }
}