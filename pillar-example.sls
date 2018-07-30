routes:
  debug: False
  backup_dir: /root/backup/ip_route 
  append:
    test_route_4:
      net: '192.168.28.0/24'
      gw: '192.168.1.101'
    test_route_1:
      net: '192.168.22.0/24'
      gw: '192.168.1.101'
    test_route_3:
      net: '192.168.44.0/24'
      gw: '192.168.1.101'


  absent:
    test_route_2:
      net: '192.168.33.0/24'

