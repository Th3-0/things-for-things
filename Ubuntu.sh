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
    echo " 7:enable/secure ssh        8:secure passwd/shadow perms"
    echo " 9:scan for known bad apps  10:scan for malware"
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
            10) clamav;;
        esac  
}

#updates1
 update() {
    apt-get update -yq
    apt-get upgrade -yq
    apt-get dist-upgrade -yq
    Run
}

#firewall2
 firewall() {
    apt-get install ufw -yq
    ufw enable 
    ufw status
    Run
}

#disable root4
 rootDisable() {
    passwd -l root
    Run
}

#clamav
 clamav() {
    apt-get install clamav -yq
    clamscan /home
    Run
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
   # find / -name "*.pdf" -type f
    echo "----OTHER----"
    find / -txt "*.txt" -type f
    Run
}

#change user passwords5
 passwrds() {
    echo "please type username account you want to change, or type q to quit"
    read -p "" user
        if [ $user = "q"]
        then 
            Run
        
        else
            passwd $user
            passwrds
        fi
}

#password Policy
 psswdPolicy() {
    apt-get install libpam-cracklib -yq
    mkdir Backups
    cp /etc/login.defs Backups
    cp /etc/pam.d/common-password Backups
    sed -i -e 's/PASS_MAX_DAYS\t[[:digit:]]\+/PASS_MAX_DAYS\t90/' /etc/login.defs
    sed -i -e 's/PASS_MIN_DAYS\t[[:digit:]]\+/PASS_MIN_DAYS\t0/' /etc/login.defs
    sed -i -e 's/difok=3\+/difok=3 ucredit=-2 lcredit=-2 dcredit=-2 ocredit=-2/' /etc/pam.d/common-password
    sed -i -e 's/sha512/sha512 remember=5/g' /etc/pam.d/common-password
    Run
 }

#securing perms
 perms() {
     chmod 640 /etc/shadow
     Run
 }
    
Run



 