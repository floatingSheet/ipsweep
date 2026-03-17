#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Benutzung: $0 <interface>"
    exit 1
fi

iface=$1
if ip addr show "$iface" > /dev/null 2>&1; then
    ip_cidr=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
    if [ -n "$ip_cidr" ]; then
        ip_addr=${ip_cidr%/*}
        snm=${ip_cidr#*/}
        echo "Interface: $iface"
        echo "IP-Adresse: $ip_addr"
        echo "Subnetzmaske (CIDR): /$snm"
    else
        echo "Keine IPv4-Adresse für $iface gefunden."
    fi
else
    echo "Interface '$iface' existiert nicht."
fi
