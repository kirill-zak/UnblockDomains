# UnblockDomains
OpenWRT scripts for unblock domains 

# How to use
Few steps

## 1. Install OpenVPN
Install OpenVPN into OpenWRT device

## 2. Install package bind-hos
```sh
opkg update
opkg install bind-host
```

## 3. Copy scripts into router
From host mashine
```sh
scp unblocker.sh /etc/openvpn/unblocker.sh
```

### Set executable flag
In router
```sh
chmod +x unblocker.sh
```


## 4. Add settings and domain configuration files
Run in folder with scripts
```sh
echo TUN=`ifconfig | grep tun | awk '{print $1}'` > settings.conf
touch domains.conf
```

## 5. Add domains
Add list of domains into `domains.conf`

## 6. Run script
```sh
./unblocker.sh
```

