#!/bin/sh

#######################################
## Intial settings                   ##
#######################################

SCRIPT_DIR=`pwd`
CONFIG_PATH="$SCRIPT_DIR/settings.conf"
DOMAINS_PATH="$SCRIPT_DIR/domains.conf"
DNS_PATH="$SCRIPT_DIR/dns.conf"

#######################################
## Check and read configuration file ##
#######################################

## Settings file
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Configuration file is not exist!" >&2
    exit 1
fi

source "$CONFIG_PATH"

## Check TUN settings
if [ -z "$TUN" ]; then
    echo "Settings [TUN] is empty!" >&2
    exit 1
fi

## Check domain configuration file
if [ ! -f "$DOMAINS_PATH" ]; then
    echo "Domains file is not exit!" >&2
    exit 1
fi

## Check DNS configuration file
if [ ! -f "$DNS_PATH" ]; then
    echo "DNS file is not exist" >&2
    exit 1
fi

#######################################
## Process dns                       ##
#######################################

while read -r DNS
do
    echo "Start to process DNS [$DNS]..." >&2

    ## Check on exist route to DNS
    DNS_EXIST="$(ip route get "$DNS" | awk 'NR==1{print $3}')"

    if [ "$DNS_EXIST" ==  "$TUN" ]; then
      echo "Route for DNS [$DNS] already exist" >&2
    else
      echo " * Adding route for DNS [$DNS]" >&2
      route add "$DNS" dev "$TUN"
    fi

    echo "End of process DNS [$DNS]" >&2
    echo "" >&2
done < "$DNS_PATH"

#######################################
## Process domains                   ##
#######################################

while read -r DOMAIN
do
    echo "Start to process domain [$DOMAIN]..." >&2

    DOMAIN_IPS="$(host -t a "$DOMAIN" | awk '{print $4}' | egrep ^[1-9] | awk -F. '{print $1"."$2"."$3".0/24"}' | sort | uniq)"

    for IP in ${DOMAIN_IPS}
    do
        IP_EXIST="$(ip route get "$IP" | awk 'NR==1{print $3}')"

        if [ "$IP_EXIST" ==  "$TUN" ]; then
          echo "Route for IP [$IP] already exist" >&2
        else
          echo " * Adding route for IP [$IP]" >&2
          route add -net "$IP" dev "$TUN"
        fi

    done

    echo "End of process domain [$DOMAIN]" >&2
    echo "" >&2
done < "$DOMAINS_PATH"

exit 0
