fastmap ()
(
        ################ USAGE SECTION ###################

        bold=$(tput bold)
        normal=$(tput sgr0)

        print_usage()
        {
                echo -e "\n${bold}Usage: ${normal}fastmap IP [-a BoxName] [-t,u,tu] [-n]"
                echo -e "\t${bold}-a BoxName, \n\t\t${normal}Add IP to hosts file"
                echo -e "\t${bold}-t, -u ${normal}or ${bold}-tu, \n\t\t${normal}TCP, UDP or Both"
                echo -e "\t${bold}-n, \n\t\t${normal}Just perform a portscan\n"

        }

        if [ "$#" -lt 1 ]; then
                print_usage
                return 1
        fi

        if [[ ! "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                print_usage
                echo -e "\n[*] Incorrect IP format. ( $1 )\n"
                return 1
        else
                IP=$1
        fi

        ################## ADD TO HOSTS ####################

        if [[ "$*" == *"-a"* ]]; then
                for arg in "$@"; do
                        if [[ $arg =~ ^[a-zA-Z]*$ ]]; then
                                BOX_NAME=$arg
                                cp /etc/hosts /etc/hosts.bak
                                echo "[!] Added $BOX_NAME to hosts."
                                printf '\n%s      %s.htb %s' "$IP" "$BOX_NAME" "$BOX_NAME" >> /etc/hosts
                        else
                                BOX_NAME=$IP
                        fi

                done
                if [[ $BOX_NAME == $IP ]]; then
                        echo -e "\nInvalid / No BoxName argument specified;"
                        echo " [-] Not editing /etc/hosts file"
                        echo " [*] nmap output name defaulting to $IP"
                fi

        fi

        ################# INITIAL PORT SCAN ###################

        if [ ! -d "nmap" ]; then
                mkdir nmap
        fi

        echo -e "\n[*] Performing initial port scan"
        if [[ "$*" == *"-u"* ]]; then
                ports=$(nmap -p- -sU --min-rate=1000 -T4 "$IP" | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
                switch="-sU"
                protocol="UDP"
        elif [[ "$*" == *"-tu"* ]]; then
                ports=$(nmap -p- -sU -sT --min-rate=1000 -T4 "$IP" | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
                switch="-sU -sT"
                protocol="TCP and UDP"
        else
                ports=$(nmap -p- --min-rate=1000 -T4 "$IP" | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
                switch="-sT"
                protocol="TCP"
        fi

        if [ -z $ports ]; then
                echo -e "\n[-] No open ports found.\n"
                return 2
        fi

        echo "[+] Open ports on $protocol: $ports."

        ################# DETAILED PORT SCAN ###################

        if [[ "$*" == *"-n"* ]]; then
                return 1
        else
                echo -e "\n[*] Performing detailed $protocol scan...\n"
                nmap $switch -sC -sV -p $ports -oA nmap/"$BOX_NAME" "$IP"
        fi

        echo -e "\n[+] All done!"

        #########################################################
)

