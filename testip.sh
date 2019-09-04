#!/bin/bash

if [ $# -le 0 ];then
	echo "expect  'dhcp' or 'static'";
fi
filebak="/etc/sysconfig/network-scripts/ifcfg-ens33.bak";
file="/etc/sysconfig/network-scripts/ifcfg-ens33";
dnsFile="/etc/resolv.conf"
ipaddr="192.168.226.133"
netmask="255.255.255.0"
gateway="192.168.226.2"
search="localdomain"
nameserver="192.168.226.2"
for item in $*
do
#	echo "hi $item ";
	if [ "-h" == "$item" ] ;then
		echo "this is help file";
	fi
	if [[ "-dhcp" == "$item"  || "dhcp" == "$item" ]]
	then
		echo "switch static to dhcp ";
		if [ -e $filebak ]
		then
		       echo "file has exist";
		       echo "to change the static ip to dhcp ,the ip may be changed after restart the network and the ssh tools maybe disconnected."
		       echo "you may fail access to your remote host unless you konw the new ip address,to continue input 'y' :"
		       read ctn
		       if [ "y" == $ctn ]
		       then
			       sed -i -e 's/BOOTPROTO="static"/BOOTPROTO="dhcp"/g' -i -e '/IPADDR/d' -i -e '/NETMASK/d' -i -e '/GATEWAY/d'  $file
		       fi
	       else
		       echo "file is not exist ,created a new copy";
		       cp $file $filebak

	       fi	

	fi
	if [[ "-static" == "$item" || "static" == "$item" ]];then
		echo "switch 'dhcp' to 'static'";
		if [ -e $filebak ]
		then
			echo "backup file has exists";
			sed -i -e 's/BOOTPROTO="dhcp"/BOOTPROTO="static"/g' -i -e '$a IPADDR='$ipaddr -i -e '$a NETMASK='$netmask -i -e '$a GATEWAY='$gateway $file
		else
			echo "file is not exists ,created a new cop"
		       cp $file $filebak

		fi
	fi
done
systemctl restart network
sed -i -e '$a search '$search -i -e '$a nameserver '$nameserver  $dnsFile
echo "the network is restarted,if still cannot access the internet ,please check the configure file $dnsFile,there should be search $search and nameserver $gateway there"
