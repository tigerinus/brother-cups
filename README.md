# brother-cups

## To run 

```
docker run --name cups -d --restart unless-stopped --network host --privileged -v /var/run/dbus:/var/run/dbus -v /dev/bus/usb:/dev/bus/usb wangxiaohu/brother-cups
```

## Add a rule to firewall (nftables)

Create a file at `/etc/nftables.d/52_cups.nft`:

```bash
#!/usr/sbin/nft -f

table inet filter {
        chain input {

                # drop ssh from wwan
                iifname "wwan*" tcp dport 631 drop comment "drop CUPS from wwan"

                # allow ssh
                tcp dport 631 accept comment "accept CUPS"

        }
}
```
