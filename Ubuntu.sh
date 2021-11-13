#!/bin/bash
 
# selection
 Run() {
    echo "██████╗░██╗░░░░░███████╗███████╗██████╗░"
    echo "██╔══██╗██║░░░░░██╔════╝██╔════╝██╔══██╗"
    echo "██████╦╝██║░░░░░█████╗░░█████╗░░██████╔╝"
    echo "██╔══██╗██║░░░░░██╔══╝░░██╔══╝░░██╔═══╝░"
    echo "██████╦╝███████╗███████╗███████╗██║░░░░░"
    echo "╚═════╝░╚══════╝╚══════╝╚══════╝╚═╝░░░░░"
    echo "________________________________________"
    echo " Please Select option you wish to run"
    echo " 1:Updates                  2:Enable Firewall"
    echo " 3:Find bad files           4:Disable rooot"
    echo " 5:Change Passwords         6:passwd Policy"
    echo " 7:enable/secure ssh        7:secure passwd/shadow perms"
    echo " 8:scan for known bad apps  9:scan for malware"
    echo " <ctrl-C> to quit"

    read -p "" input
        case $input in
            1) update;;
            2) firewall;;
            3) badFiles;;
            4) rootDisable;;
            5) passwrds;;
            6) psswdPolicy;;
            7) ssh;;
            8) perms;;
            9) clamav;;
        esac  
}

#updates1
 update() {
    apt-get update -yq
    apt-get upgrade -yq
    apt-get dist-upgrade -yq
}

#firewall2
 firewall() {
    apt-get install ufw -yq
    ufw enable 
    ufw status
}

#disable root
 rootDisable() {
    passwd -l root
}

#clamav
 clamav() {
    apt-get install clamav -yq
    clamscan /home
}

#unauthorized files3
 badFiles() {
    echo "----MEDIA----"
    find / -name "*.mp4" -type f
    find / -name "*.mp3" -type f
    find / -name "*.mov" -type f
    find / -name "*.wav" -type f
    echo "----PICTURES----"
    find / -name "*.png" -type f
    find / -name "*.jpg" -type f
    find / -name "*.jpeg" -type f
    find / -name "*.pdf" -type f
    echo "----OTHER----"
    find / -txt "*.txt" -type f
}

#change user passwords
 passwrds() {
    echo "please type username account you want to change, or type q to quit"
    read -p "" user
        if [ $user = "q"]
        then 
            Run
        
        else
            passwd $user
            m*M5->2_KT/~-m84
            m*M5->2_KT/~-m84
}
    




 