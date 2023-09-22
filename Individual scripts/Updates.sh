#!/bin/bash
#UPDATES

#focal
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu/ focal" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu\/ focal/c\deb http:\/\/archive.ubuntu.com\/ubuntu\/ focal main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe" >> /etc/apt/sources.list
fi

#focal-updates
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu/ focal-updates" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu\/ focal-updates/c\deb http:\/\/archive.ubuntu.com\/ubuntu\/ focal-updates main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe" >> /etc/apt/sources.list
fi

#focal-security
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu focal-security" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu focal-security/c\deb http:\/\/archive.ubuntu.com\/ubuntu focal-security main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu focal-security main restricted universe" >> /etc/apt/sources.list
fi

#focal-backports
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu/ focal-backports" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu\/ focal-backports/c\deb http:\/\/archive.ubuntu.com\/ubuntu\/ focal-backports main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu/ focal-backports main restricted universe" >> /etc/apt/sources.list
fi


#canonical Partner
#focal-backports
if grep -iq "deb http://us.archive.canonical.com/ubuntu focal" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/archive.canonical.com\/ubuntu focal/c\deb http:\/\/archive.canonical.com\/ubuntu focal partner' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu focal partner" >> /etc/apt/sources.list
fi

if grep -iq "deb-src http://us.archive.canonical.com/ubuntu focal" /etc/apt/sources.list
then
    sudo sed -i '/deb-src http:\/\/archive.canonical.com\/ubuntu focal/c\deb-src http:\/\/archive.canonical.com\/ubuntu focal partner' /etc/apt/sources.list
else
    echo "deb-src http://us.archive.ubuntu.com/ubuntu focal partner" >> /etc/apt/sources.list
fi

sudo apt-get install unattended-upgrades -yq
sudo systemctl start unattended-upgrades -yq
sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq 
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq 
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yq 

