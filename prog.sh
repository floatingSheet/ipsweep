#!/bin/bash

# Prüfen, ob ein Parameter übergeben wurde
if [ $# -eq 0 ]; then
    echo "Benutzung: $0 <interface>"
    exit 1
fi

iface=$1

# Prüfen, ob das Interface existiert
if ip addr show "$iface" > /dev/null 2>&1; then
    # IPv4-Adresse auslesen
    ip_addr=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    
    if [ -n "$ip_addr" ]; then
        echo "Die IP-Adresse von $iface ist: $ip_addr"
    else
        echo "Keine IPv4-Adresse für $iface gefunden."
    fi
else
    echo "Interface '$iface' existiert nicht."
fi
