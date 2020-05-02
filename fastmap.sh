fastmap ()
{	
	# $1 = IP
	# $2 = BOX NAME
	if [ "$#" -lt 2 ]; then
		echo "Usage: map <IP> <BoxName> [-a](add to hosts) [-t,u,tu](tcp, udp, both)"
		return 1
	fi

	if [[ "$*" == *"-a"* ]]; then
		cp /etc/hosts /etc/hosts.bak
		echo "[!] Added "$2" to hosts."
		printf '%s	%s.htb %s' "$1" "$2" "$2" >> /etc/hosts
	fi

	echo -e "\n[*] Performing initial port scan"
	ports=$(nmap -p- --min-rate=1000 -T4 "$1" | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)

	echo "[!] Open ports: $ports."
	
	if [ ! -d "nmap" ]; then
		mkdir nmap
	fi
	
	if [[ "$*" == *"-u"* ]]; then
		echo -e "\n[*] Doing UDP scan...\n"
		nmap -sC -sU -sV -p $ports -oA nmap/"$2" "$1"
	elif [[ "$*" = *"-tu"* ]]; then
		echo -e "\n[*] Doing TCP and UDP scan...\n"
		nmap -sC -sU -sT -sV -p $ports -oA nmap/"$2" "$1"
	else
		echo -e "\n[*] Doing TCP scan...\n"
		nmap -sC -sV -p $ports -oA nmap/"$2" "$1"
	fi

	echo -e "\n[+] All done!"

}
