# ip_route-formula
SaltStack formula to manage linux routes for salt 2016

This formula created to manage ip routes on old salt-minions (Debian 9, salt-minion 2016.11.2 (Carbon)).   
Also state create backup before delete or add route, for debug can show final route table.


# Usage:

## Add route:

```
routes:
  append:
    some_route:
      net: '192.168.28.0/24'  # destination network
      gw: '192.168.1.101'     # gateway to destination network
```

## Delete route:

```
routes:
  absent:
    some_not_used_route:
      net: '192.168.33.0/24'  # destination network
```

## Enable debug

```
routes:
  debug: False
```

## Change backup directory

```
routes:
  backup_dir: /root/backup/ip_route
```



