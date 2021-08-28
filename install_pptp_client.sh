#!/bin/bash

apt-get update
apt-get upgrade -y

apt-get -y install pptp-linux

#========= Настройки ===============

VPN_NAME="vpn_pptp"                 #Имя PPTP-подключения (можно не менять)

VPN_SERVER_IP="**********"          #Адрес или DNS-имя PPTP-сервера,куда подключаемся
VPN_USER="**********"               #Логин pptp
VPN_PASSWORD="**********"           #Пароль pptp

VPN_NETWORK="10.0.0.0/24"           #IP-адрес и маска сети PPTP-соединения для маршрутизации

VPN_FROM_INTERFACE="eth0"           #Интерфейс для подключения к VPN-серверу
ROUTE_METRIC="1"                    #Метрика маршрута к VPN-серверу

#===================================

FILE_DIR="/etc/ppp/peers/$VPN_NAME"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo "pty \"pptp $VPN_SERVER_IP --nolaunchpppd\""
    echo "name $VPN_USER        #логин"
    echo "remotename $VPN_NAME  #имя соединения"
    echo "require-mppe-128      #включаем поддержку MPPE"
    echo "persist               #переподключаться при обрыве"
    echo "maxfail 10            #количество попыток переподключения"
    echo "holdoff 10            #интервал между подключениями"
    echo "unit 0                #номер ppp интерфейса"
    echo "#defaultroute         #создавать маршрут по умолчанию"
    echo "#replacedefaultroute  #принудительно изменять маршрут по умолчанию"
    echo "file /etc/ppp/options.pptp"
    echo "ipparam $VPN_NAME"
} > $FILE_DIR

#===================================

FILE_DIR="/etc/ppp/chap-secrets"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo "#Secrets for authentication using CHAP"
    echo "#client  server  secret  IP addresses"
    echo "$VPN_USER * $VPN_PASSWORD *"
} > $FILE_DIR

chmod 600 $FILE_DIR


#========= Маршрутизация ===========

FILE_DIR="/etc/ppp/ip-up.d/route-traffic"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo "#!/bin/bash"
    echo ""
    echo "VPN_NETWORK=\"$VPN_NETWORK\""
    echo "IFACE=\"ppp0\""
    echo ""
    echo "route add -net \${VPN_NETWORK} dev \${IFACE}"
} > $FILE_DIR

chmod +x $FILE_DIR

#========== Настройка сети ==========

FILE_DIR="/etc/network/interfaces"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo ""    
    echo "auto tunnel"
    echo "iface tunnel inet ppp"
    echo "provider $VPN_NAME"
} >> $FILE_DIR

#======== Дополнительный скрипт подключения (для теста) =======

FILE_DIR="pptp_client.sh"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo "#!/bin/bash"
    echo ""
    echo "VPN_NAME=\"$VPN_NAME\""
    echo ""
    echo "PING_HOST=\"$VPN_SERVER_IP\""
    echo "PING_RES=\`ping -c 2 \$PING_HOST\`"
    echo "PING_LOSS=\`echo \$PING_RES : | grep -oP '\\d+(?=% packet loss)'\`"
    echo ""
    echo "if [ \"100\" -eq \"\$PING_LOSS\" ]; then"
    echo "  echo \"Starting : \$PING_HOST\""
    echo "  pon \$VPN_NAME" 
    echo "else"
    echo "  echo \"Already running : \$PING_HOST\"" 
    echo "fi"
} > $FILE_DIR

chmod +x $FILE_DIR

#======== Дополнительный скрипт для маршрутизации подключения к VPN-сервеу =======

FILE_DIR="route_vpn_server.sh"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo "#!/bin/bash"
    echo ""
    echo "VPN_SERVER_IP=\"$VPN_SERVER_IP\""
    echo "VPN_FROM_INTERFACE=\"$VPN_FROM_INTERFACE\""
    echo "ROUTE_METRIC=\"$ROUTE_METRIC\""
    echo ""
    echo "route del \${VPN_SERVER_IP}"
    echo ""
    echo "route add -host \${VPN_SERVER_IP} metric \${ROUTE_METRIC} dev \${VPN_FROM_INTERFACE}"
} > $FILE_DIR

chmod +x $FILE_DIR
