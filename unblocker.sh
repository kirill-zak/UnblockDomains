#!/bin/sh

## Intial settings
SCRIPT_DIR=`pwd`
CONFIG_PATH="$SCRIPT_DIR/settings.conf"
DOMAINS_PATH="$SCRIPT_DIR/domains.conf"

## Check and read configuration file 
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

## Add Google DNS into route table
route add 8.8.8.8/32 dev $TUN;
route add 8.8.4.4/32 dev $TUN;
route add 77.88.8.8/32 dev $TUN;

## Process domains
while read -r DOMAIN
do
    echo "Start to process domain [$DOMAIN]..." >&2

    DOMAIN_IPS="$(host -t a "$DOMAIN" | awk '{print $4}' | egrep ^[1-9] | awk -F. '{print $1"."$2"."$3".0/24"}' | sort | uniq)"

    for IP in ${DOMAIN_IPS}
    do
        echo " * Adding route for IP [$IP]"
        route add -net "$IP" dev "$TUN"
    done

    echo "End of process domain [$DOMAIN]" >&2
    echo "" >&2
done < "$DOMAINS_PATH"

exit 0
