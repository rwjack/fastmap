fastmap ()
{	
	# $1 = IP
	# $2 = BOX NAME
	if [ "$#" -lt 2 ]; then
		echo "Usage: map <IP> <BoxName>"
		echo -e "\t[-a](add to hosts) [-t,u,tu](tcp, udp, both) [-n](just perform portscan)"
		return 1
	fi

	if [[ "$*" == *"-a"* ]]; then
		cp /etc/hosts /etc/hosts.bak
		echo "[!] Added "$2" to hosts."
		printf '%s	%s.htb %s' "$1" "$2" "$2" >> /etc/hosts
	fi

	if [ ! -d "nmap" ]; then
		mkdir nmap
	fi

	echo -e "\n[*] Performing initial port scan"
	if [[ "$*" == *"-u"* ]]; then
		ports=$(nmap -p- -sU --min-rate=1000 -T4 "$1" | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
		switch="-sU"
		protocol="UDP"
	elif [[ "$*" == *"-tu"* ]]; then
		ports=$(nmap -p- -sU -sT --min-rate=1000 -T4 "$1" | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
		switch="-sU -sT"
		protoco="TCP and UDP"
	else
		ports=$(nmap -p- --min-rate=1000 -T4 "$1" | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
		switch="-sT"
		protocol="TCP"
	fi

	echo "Open ports on $protocol: $ports."

	if [[ "$*" == *"-n"* ]]; then
		return 2
	else
		echo -e "\n[*] Performing detailed $protocol scan...\n"
		nmap $switch -sC -sV -p $ports -oA nmap/"$2" "$1" 
	fi

	echo -e "\n[+] All done!"

}
