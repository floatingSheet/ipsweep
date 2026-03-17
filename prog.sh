#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Benutzung: $0 <interface> <output-datei>"
    exit 1
fi

iface=$1
output_file=$2
if ip addr show "$iface" > /dev/null 2>&1; then
    ip_cidr=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
    
    if [ -n "$ip_cidr" ]; then
        ip_addr=${ip_cidr%/*}
        cidr=${ip_cidr#*/}
        mask=""
        remaining=$cidr
        for i in {1..4}; do
            if [ $remaining -ge 8 ]; then
                mask+=255
                remaining=$((remaining - 8))
            else
                val=$((256 - 2**(8 - remaining)))
                mask+=$val
                remaining=0
            fi
            [ $i -lt 4 ] && mask+=.
        done

        echo "Interface: $iface"
        echo "IP-Adresse: $ip_addr"
        echo "Subnetzmaske (CIDR): /$cidr"
        echo "Subnetzmaske (klassisch): $mask"

        IFS=. read -r i1 i2 i3 i4 <<< "$ip_addr"
        IFS=. read -r m1 m2 m3 m4 <<< "$mask"

        net1=$((i1 & m1))
        net2=$((i2 & m2))
        net3=$((i3 & m3))
        net4=$((i4 & m4))

        echo "Starte Ping auf Netzwerk: $net1.$net2.$net3.0/$cidr"
        > "$output_file"

        for host in {1..254}; do
            target="$net1.$net2.$net3.$host"
            ping -c 1 -W 1 "$target" &> /dev/null
            if [ $? -eq 0 ]; then
                echo "$target erreichbar" | tee -a "$output_file"
            fi
        done

        echo "Fertige Ping-Liste in $output_file"
    else
        echo "Keine IPv4-Adresse für $iface gefunden."
    fi
else
    echo "Interface '$iface' existiert nicht."
fi
