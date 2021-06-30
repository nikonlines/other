#!/bin/bash

apt-get update
apt-get upgrade -y

apt-get -y install ppp wvdial usb-modeswitch

#========= Настройки =============

CONNECT_NAME="3G_MODEM"

MODEM_PORT="/dev/ttyUSB0"
MODEM_BAUND="115200"

#=================================

FILE_DIR="/etc/wvdial.conf"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo "[Dialer $CONNECT_NAME]" 
    echo "Init1 = ATZ"
    echo "Init2 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0"
    echo "Init3 = AT+CGDCONT=1,\"IP\",\"internet\"" 
    echo "Modem Type = USB Modem"
    echo "Modem = $MODEM_PORT" 
    echo "Baund = $MODEM_BAUND"
    echo "New PPPD = yes"
    echo "Auto Reconnect = on"
    echo "Phone = *99#" 
    echo "ISDN = 0"
    echo "Username = { }" 
    echo "Password = { }" 
    echo "Ask Password = 0"
    echo "Stupid Mode = 1"
} > $FILE_DIR

#========== Настройка сети ==========

FILE_DIR="/etc/network/interfaces"

if [ -f $FILE_DIR ]; then
    echo "The $FILE_DIR file exists, create $FILE_DIR.bak file"
    cp $FILE_DIR $FILE_DIR".bak"
fi

{
    echo ""    
    echo "auto ppp0"
    echo "iface ppp0 inet wvdial"
    echo "provider $CONNECT_NAME"
} >> $FILE_DIR

#=================================
