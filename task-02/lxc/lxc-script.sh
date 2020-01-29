#!/bin/bash

yes | apt-get install mc
yes | apt-get install lxc lxc-templates

# cat <<PAST | tee -a /etc/lxc/lxc-usernet
# your-username veth lxcbr0 10
# PAST

cat <<PAST | tee -a /etc/default/lxc-net
USE_LXC_BRIDGE="true"
LXC_BRIDGE="lxcbr0"
LXC_ADDR="192.168.1.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="192.168.1.0/24"
LXC_DHCP_RANGE="192.168.1.2,192.168.1.254"
LXC_DHCP_MAX="253"
LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
LXC_DOMAIN=""
PAST

cat <<PAST | tee /etc/lxc/dnsmasq.conf
# dhcp-host=statsite,10.0.3.100
# dhcp-host=dynasite,10.0.3.101
dhcp-hostsfile=/etc/lxc/dnsmasq-hosts.conf
PAST

cat <<PAST | tee /etc/lxc/dnsmasq-hosts.conf
statsite,192.168.1.100
dynasite,192.168.1.101
PAST

sudo mkdir -p /var/lib/lxd/networks/lxcbr0/
cat <<PAST | tee /var/lib/lxd/networks/lxcbr0/dnsmasq.hosts
192.168.1.100,statsite
192.168.1.101,dynasite
PAST

sudo mkdir -p /etc/dnsmasq.d-available/
cat <<PAST | tee /etc/dnsmasq.d-available/lxc
bind-interfaces
except-interface=lxcbr0
PAST

sudo systemctl enable lxc-net
sudo systemctl start lxc-net

cat <<PAST | tee /etc/lxc/default.conf
lxc.net.0.type  = veth
lxc.net.0.flags = up
lxc.net.0.link  = lxcbr0
lxc.apparmor.profile = unconfined
PAST

sudo lxc-create -t download -n statsite -- -d centos -r 8 -a amd64
sudo lxc-create -t download -n dynasite -- -d centos -r 8 -a amd64


sudo lxc-start -n statsite
sudo lxc-start -n dynasite

sleep 10

sudo lxc-attach statsite -- yum -y install httpd
sudo lxc-attach statsite -- systemctl enable httpd
sudo lxc-attach statsite -- systemctl start httpd


sudo lxc-attach dynasite -- yum -y install httpd
sudo lxc-attach dynasite -- yum -y install php
sudo lxc-attach dynasite -- systemctl enable httpd
sudo lxc-attach dynasite -- systemctl start httpd

# Create site directories 'static' and 'dynamic'
sudo mkdir -pv /var/lib/lxc/statsite/rootfs/var/www/static/
sudo chmod -v 775 /var/lib/lxc/statsite/rootfs/var/www/static/
sudo chown -vR root:root /var/lib/lxc/statsite/rootfs/var/www/static/
sudo cp /vagrant/index.html /var/lib/lxc/statsite/rootfs/var/www/static/

sudo mkdir -pv /var/lib/lxc/dynasite/rootfs/var/www/dynamic/
sudo chmod -v 775 /var/lib/lxc/dynasite/rootfs/var/www/dynamic
sudo chown -vR root:root /var/lib/lxc/dynasite/rootfs/var/www/dynamic
sudo cp /vagrant/index.php /var/lib/lxc/dynasite/rootfs/var/www/dynamic/

# Config VirtualHosts 
sudo mkdir -pv /var/lib/lxc/statsite/etc/httpd/sites-available
sudo chmod -v 775 /var/lib/lxc/statsite/etc/httpd/sites-available
sudo chown -vR root:root /var/lib/lxc/statsite/etc/httpd/sites-available

sudo mkdir -pv /var/lib/lxc/statsite/etc/httpd/sites-enabled
sudo chmod -v 775 /var/lib/lxc/statsite/etc/httpd/sites-enabled
sudo chown -vR root:root /var/lib/lxc/statsite/etc/httpd/sites-enabled

# Config VirtualHosts  
sudo mkdir -pv /var/lib/lxc/dynasite/etc/httpd/sites-available
sudo chmod -v 775 /var/lib/lxc/dynasite/etc/httpd/sites-available
sudo chown -vR root:root /var/lib/lxc/dynasite/etc/httpd/sites-available

sudo mkdir -pv /var/lib/lxc/dynasite/etc/httpd/sites-enabled
sudo chmod -v 775 /var/lib/lxc/dynasite/etc/httpd/sites-enabled
sudo chown -vR root:root /var/lib/lxc/dynasite/etc/httpd/sites-enabled




#sudo rm /var/lib/lxc/statsite/rootfs/etc/httpd/conf.d/welcome.conf
#sudo rm /var/lib/lxc/statsite/rootfs/etc/httpd/conf.d/userdir.conf
#sudo rm /var/lib/lxc/statsite/rootfs/etc/httpd/conf.d/autoindex.conf

#sudo rm /var/lib/lxc/dynasite/rootfs/etc/httpd/conf.d/welcome.conf
#sudo rm /var/lib/lxc/dynasite/rootfs/etc/httpd/conf.d/userdir.conf
#sudo rm /var/lib/lxc/dynasite/rootfs/etc/httpd/conf.d/autoindex.conf

# Enabling necessary files .conf
sudo cp /vagrant/static.conf /var/lib/lxc/statsite/rootfs/etc/httpd/conf.d/static.conf
sudo cp /vagrant/dynamic.conf /var/lib/lxc/dynasite/rootfs/etc/httpd/conf.d/dynamic.conf

# Enabling VirtualHosts
sudo cp /vagrant/static.conf /var/lib/lxc/statsite/rootfs/etc/httpd/sites-available/static.conf
sudo cp /vagrant/dynamic.conf /var/lib/lxc/dynasite/rootfs/etc/httpd/sites-available/dynamic.conf

sudo ln -svf /var/lib/lxc/statsite/rootfs/etc/httpd/sites-available/static.conf /var/lib/lxc/statsite/rootfs/etc/httpd/sites-enabled/static.conf
sudo ln -svf /var/lib/lxc/dynasite/etc/httpd/sites-available/dynamic.conf /var/lib/lxc/dynasite/rootfs/etc/httpd/sites-enabled/dynamic.conf

sudo sed -i.bak -e "/Listen 80/a Listen 81" /var/lib/lxc/dynasite/rootfs/etc/httpd/conf/httpd.conf

sudo rm /var/lib/lxc/statsite/rootfs/etc/httpd/conf.d/welcome.conf
sudo rm /var/lib/lxc/dynasite/rootfs/etc/httpd/conf.d/welcome.conf

sudo lxc-attach statsite -- systemctl restart httpd
sudo lxc-attach dynasite -- systemctl restart httpd

statsiteIP=$(sudo lxc-info -i -n statsite | cut -d : -f 2)
dynasiteIP=$(sudo lxc-info -i -n dynasite | cut -d : -f 2)
sudo iptables -F
# sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.0.3.14:80
sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination ${statsiteIP}:80
sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 81 -j DNAT --to-destination ${dynasiteIP}:81

sudo lxc-ls -f