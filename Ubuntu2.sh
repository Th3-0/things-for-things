#!/bin/bash

echo "========================================"
echo "██████╗░██╗░░░░░███████╗███████╗██████╗░"
echo "██╔══██╗██║░░░░░██╔════╝██╔════╝██╔══██╗"
echo "██████╦╝██║░░░░░█████╗░░█████╗░░██████╔╝"
echo "██╔══██╗██║░░░░░██╔══╝░░██╔══╝░░██╔═══╝░"
echo "██████╦╝███████╗███████╗███████╗██║░░░░░"
echo "╚═════╝░╚══════╝╚══════╝╚══════╝╚═╝░░░░░"
echo "========================================"
echo "This Script runs basic CyberPatriot Setup"
echo "Updates, Firewall, Password Policy,"
echo "secure passwords, users&groups"
echo "========================================"
echo "Written 2023: Theo Bourgeois"
echo "========================================"


update() {
    echo "check apt sources first"
    echo "================================================================" 
    echo "                          UPDATES                               "
    echo "================================================================"
    #source control
    sed -i '/deb http:\/\/archive.ubuntu.com\/ubuntu xenial /c\deb http:\/\/archive.ubuntu.com\/ubuntu xenial main universe restricted' /etc/apt/sources.list
    sed -i '/deb http:\/\/archive.ubuntu.com\/ubuntu xenial-security/c\deb http:\/\/archive.ubuntu.com\/ubuntu xenial-security main universe restricted' /etc/apt/sources.list
    sed -i '/deb http:\/\/archive.ubuntu.com\/ubuntu xenial-updates/c\deb http:\/\/archive.ubuntu.com\/ubuntu xenial-updates main universe restricted' /etc/apt/sources.list
    sed -i '/deb http:\/\/archive.canonical.com\/ubuntu xenial/c\deb http:\/\/archive.ubuntu.com\/ubuntu xenial partner' /etc/apt/sources.list
    sed -i '/deb-src http:\/\/archive.ubuntu.com\/ubuntu xenial/c\deb http:\/\/archive.ubuntu.com\/ubuntu xenial partner' /etc/apt/sources.list
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq 
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq 
    sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yq 
    sudo apt-get install unattended-upgrades -yq
    sudo systemctl start unattended-upgrades -yq
    Confirmation
}

firewall() {
    echo "================================================================" 
    echo "                          UFW STATUS                               "
    echo "================================================================"
    apt-get install ufw -yq
    ufw enable 
    sudo ufw default allow outgoing
    sudo ufw default deny incoming
    sudo ufw logging medium
    sudo ufw status verbose
    Confirmation
}

rootDisable() {
    echo "================================================================"
    echo "                          ROOT DISABLE                               "
    echo "================================================================" 
    passwd -l root 
    Confirmation
}

passwrds() {
    echo "================================================================" 
    echo "                     PASSWORDS AND USERS                               "
    echo "     output for this is stored in separate UserChangeLog file"
    echo "================================================================"
    echo "ALL PASSWORDS EXCEPT ROOT AND MAIN USER WILL BE CHANGED TO [Cyb3rPatr!0t$]"
    CurrentUser=$(whoami)
    apt install members -yq
    if [ $CurrentUser != "root" ]
    then
        echo "============================================"
        echo "   THIS MUST SCRIPT MUST BE RUN WITH SUDO"
        echo "============================================"
        exit
    fi
    echo "========================================================================================="
    echo "   THIS SCRIPT WILL PERMANANTLY MODIFY USERS. IF YOU DO NOT WISH TO CONTINUE EXIT NOW."
    echo "========================================================================================="

    updateUserDefs() {
    mapfile -t AllCurrentUsers < <(getent passwd {1000..1500} | cut -d: -f1) 
    mapfile -t CurrentAdminUsers < <(members sudo)
    mapfile -t CurrentNormUsers < <(echo ${AllCurrentUsers[@]} ${CurrentAdminUsers[@]} | tr ' ' '\n' | sort | uniq -u)
    }
    updateUserDefs
    CurrentAdminUsers+=("root")

    #enter Admins from README
    NeededUsers=($CurrentUser)
    read -p "Please enter Current/Main cyberpat user: " MainUser
    NeededUsers+=($MainUser)


    enteradmins() {
        read -p "Please list all Admin Users, When done type[done.]: " adminanswer
        if [ $adminanswer == "done." ]
        then 
            return 1
        elif [ $adminanswer != $CurrentUser ]
        then 
            NeededUsers+=($adminanswer)
            enteradmins
        elif  [ $adminanswer == $CurrentUser ]
        then
            enteradmins
        elif [ $adminanswer == $MainUser ]
        then 
            enteradmins
        fi
    }
    enteradmins
    enterStandard() {
    read -p "Please list all Standard Users, When done type [done.]: " StandardAnswer
    if [ $StandardAnswer != "done." ]
    then 
        NeededStandard+=($StandardAnswer)
        enterStandard
    fi
    return 1
    }
    enterStandard
    #collectGroup info(make better later)
    read -ap "Groups to add(if none press enter): " groupAdd
    read -ap "Users to add to group, ex: [group] [user1] [user2]: " UGPairing1
    read -p "do want to add to other group? y or n: " gpq
    if [ $gpq == "y" ]
    then
        read -ap "Users to add to group, ex: [group] [user1] [user2]: " UGPairing2
    fi


    #admin user differences
    mapfile -t AdminDiffs < <(echo ${CurrentAdminUsers[@]} ${NeededUsers[@]} | tr ' ' '\n' | sort | uniq -u)

    for (( i=0; i<${#AdminDiffs[@]}; i++ ));
    do
        if [[ ${NeededUsers[*]} =~ ${AdminDiffs[i]} ]]
        then #if user is on README but not currently admin
            if [[ ${CurrentNormUsers[*]} =~ ${AdminDiffs[i]} ]]
            then # user is a standard user that needs to be upgraded
                usermod -aG sudo ${AdminDiffs[i]}
                usermod -aG adm ${AdminDiffs[i]}
                echo "change standard user ${AdminDiffs[i]} to admin" >> UserChangeLog
            elif [[ ! ${CurrentNormUsers[*]} =~ ${AdminDiffs[i]} ]]
            then # user is not present on system
                useradd -s /bin/bash -m -G sudo ${AdminDiffs[i]}
                echo "add admin user ${AdminDiffs[i]}" >> UserChangeLog
            fi
        elif [[ ! ${NeededUsers[*]} =~ ${AdminDiffs[i]} ]]
        then #user is on system but not readme
            if [[  ${NeededStandard[*]} =~ ${AdminDiffs[i]} ]]
            then
                deluser ${AdminDiffs[i]} sudo
                echo "downgrade Admin ${AdminDiffs[i]} to standard" >> UserChangeLog 
            else
                userdel -rf ${AdminDiffs[i]}
                echo "remove user ${AdminDiffs[i]}" >> UserChangeLog

            fi

        fi
    done
    #==================STANDARD USERS==============
    #update users
    updateUserDefs
    #standard user differences
    mapfile -t StandardDiffs < <(echo ${CurrentNormUsers[@]} ${NeededStandard[@]} | tr ' ' '\n' | sort | uniq -u)

    for (( i=0; i<${#StandardDiffs[@]}; i++ ));
    do
        if [[ ${NeededStandard[*]} =~ ${StandardDiffs[i]} ]]
        then #if user is on README but not currently on system
            if [[ ${CurrentAdminUsers[*]} =~ ${StandardDiffs[i]} ]]
            then #user is admin that needs to be downgraded(shouldnt happen but is here just in case)
                deluser ${StandardDiffs[i]} sudo
                deluser ${StandardDiffs[i]} adm
                echo "change admin ${StandardDiffs[i]} to standard user" >> UserChangeLog
            elif [[ ! ${CurrentAdminUsers[*]} =~ ${StandardDiffs[i]} ]]
            then # user is not present on system
                useradd -s /bin/bash -m ${StandardDiffs[i]}
                echo "add standard user ${StandardDiffs[i]}" >> UserChangeLog
            fi
        elif [[ ! ${NeededStandard[*]} =~ ${StandardDiffs[i]} ]]
        then #user is on system but not Readme
            if [[  ${NeededUsers[*]} =~ ${StandardDiffs[i]} ]]
            then #(again somewhat redundant) user is supposed to be admin
                usermod -aG sudo ${StandardDiffs[i]}
                usermod -aG adm ${StandardDiffs[i]}
                echo "upgrade standard ${StandardDiffs[i]} to admin" >> UserChangeLog
            else #user should not be on machine
                userdel -rf ${StandardDiffs[i]}
                echo "remove user ${StandardDiffs[i]}" >> UserChangeLog
            fi
        fi
    done

    if [ ${groupAdd[@]} != "" ]
    then
        for i in ${groupAdd[@]}
        do
            sudo groupadd $i
        done
    fi

    if [ ${UGPairing1[@]} != "" ]
    then
        for (( i=1; i<${#UGPairing1[@]}; i++ ));
        do
            sudo usermod -a -G ${UGPairing1[0]} $i
        done
    fi

    if [ ${UGPairing2[@]} != "" ]
    then
        for (( i=1; i<${#UGPairing2[@]}; i++ ));
        do
            sudo usermod -a -G ${UGPairing2[0]} $i
        done
    fi





    clear
    #=============PASSWORDS============
    updateUserDefs
    #====================================================================================================================
    #FOR THE LOVE OF ALL THAT IS HOLY PLEASE NEVER DO THIS ON SOMETHING THAT ISN'T A CYBERPATRIOTS COMPETITION.
    #IT IS HORRIBLY INSECURE(cyberpatriots doesn't detect or care though). IT IS A STUPID FUCKING WORKAROUND FOR SPEED 
    #BASICALLY MAKES PASSWORD VIEWABLE BY ANYBODY WHO HAS ACCESS TO PS COMMAND.
    #========================================================================================================================
    for (( i=0; i<${#AllCurrentUsers[@]}; i++ ));
    do
        if [ ${AllCurrentUsers[i]} != $MainUser ]
        then
            echo "changing password for ${AllCurrentUsers[i]}"
            echo "${AllCurrentUsers[i]}:Cyb3rPatr!0t$" | chpasswd
        fi
    done
    Confirmation
}