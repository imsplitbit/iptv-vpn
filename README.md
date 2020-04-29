# iptv-vpn
Proxy IPTV through VPN tunnel

Docker container that will instantiate an openvpn tunnel for proxying iptv traffic.

The conatiner will make use of iptables killswitch to ensure your ip isn't leaked out in the case of a tunnel failure.

Most of this was taken from DyonR's JackettVPN [repo](https://github.com/DyonR/docker-Jackettvpn)