#!/bin/bash
 
# selection
Run() {
    clear
    echo "██████╗░██╗░░░░░███████╗███████╗██████╗░"
    echo "██╔══██╗██║░░░░░██╔════╝██╔════╝██╔══██╗"
    echo "██████╦╝██║░░░░░█████╗░░█████╗░░██████╔╝"
    echo "██╔══██╗██║░░░░░██╔══╝░░██╔══╝░░██╔═══╝░"
    echo "██████╦╝███████╗███████╗███████╗██║░░░░░"
    echo "╚═════╝░╚══════╝╚══════╝╚══════╝╚═╝░░░░░"
    echo "========================================"
    echo "NOTE: ONLY ENABLE SSH IF IN README\n*ssh will not be run in all"
    echo "========================================"
    echo "BEFORE UPDATING SELECT APT SOURCES"
    echo "========================================"
    echo " Please Select option you wish to run"
    echo " 1:Updates                  2:Enable Firewall"
    echo " 3:Find bad files           4:Disable rooot"
    echo " 5:Change Passwords         6:passwd Policy"
    echo " 7:enable/secure ssh        8:secure passwd/shadow perms"
    echo " 9:scan for known bad apps  10:scan for malware"
    echo " 11:Install Lynis"
    echo " <ctrl-C> to quit"

    read -p "" input
        case $input in
            #1) update;;
            2) firewall;;
            3) badFiles;;
            4) rootDisable;;
            5) passwrds;;
            6) psswdPolicy;;
            7) ssh;;
            8) perms;;
            9) badPrograms;;
            10) clamav;;
            11) lynis;;
            12) all;;
        esac  
}

#updates-1
update() {
    echo "check apt sources first"
    echo "================================================================" >> ScriptLogs
    echo "                          UPDATES                               " >> ScriptLogs
    echo "================================================================" >> ScriptLogs
    apt-get update -yq >> ScriptLogs
    apt-get upgrade -yq >> ScriptLogs
    apt-get dist-upgrade -yq >> ScriptLogs
    Confirmation
}

#firewall-2
firewall() {
    echo "================================================================" >> ScriptLogs
    echo "                          UFW STATUS                               " >> ScriptLogs
    echo "================================================================" >> ScriptLogs
    apt-get install ufw -yq
    ufw enable 
    ufw status >> ScriptLogs
    sudo ufw allow outgoing
    sudo ufw deny incoming
    Confirmation
}

#install Lynis-11
lynis() {
    read -p "has lynis been installed yet?  y:n " LynisAnswer
    if [ $LynisAnswer == "n" ] then
        sudo apt-get install git
        git clone https://github.com/CISOfy/lynis
        cd lynis && ./lynis audit system
    fi
    cd lynis && ./lynis audit system
}

#disable_root-4
rootDisable() {
    echo "================================================================" >> ScriptLogs
    echo "                          ROOT DISABLE                               " >> ScriptLogs
    echo "================================================================" >> ScriptLogs
    passwd -l root >> ScriptLogs
    Confirmation
}

#clamav-10
clamav() {
    echo "================================================================" >> ScriptLogs
    echo "                           ClamAV                               " >> ScriptLogs
    echo "================================================================" >> ScriptLogs
    apt-get install clamav -yq >> ScriptLogs
    clamscan /home >> ScriptLogs
    Confirmation
}

#unauthorized_files-3
badFiles() {
    echo "================================================================" >> ScriptLogs
    echo "                          UFW STATUS                               " >> ScriptLogs
    echo "   These files are stored in separate Badfiles.log file            " >> ScriptLogs
    echo "================================================================" >> ScriptLogs
    echo "----MEDIA----" >> Badfiles.log
    find /home -name "*.mp4" -type f >> Badfiles.log
    find /home -name "*.mp3" -type f >> Badfiles.log
    find /home -name "*.mov" -type f >> Badfiles.log
    find /home -name "*.wav" -type f >> Badfiles.log
    echo "----PICTURES----" >> Badfiles.log
    find /home -name "*.png" -type f >> Badfiles.log
    find /home -name "*.jpg" -type f >> Badfiles.log
    find /home -name "*.jpeg" -type f >> Badfiles.log
    find /home -name "*.pdf" -type f >> Badfiles.log
    echo "----OTHER----" >> Badfiles.log
    find /home -name "*.txt" -type f >> Badfiles.log
    find /home -name "*.docx" -type f >> Badfiles.log
    echo "complete:  If nothing found initially try enabling txt files"
    Confirmation
}

#change_user_passwords-5
passwrds() {
    echo "================================================================" >> ScriptLogs
    echo "                     PASSWORDS AND USERS                               " >> ScriptLogs
    echo "     output for this is stored in separate UserChangeLog file" >> ScriptLogs
    echo "================================================================" >> ScriptLogs
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
    clear
    echo "  check UserChangeLog file to find, troubleshoot or review what was edited"
    echo "============================================================================"
    echo "                                PASSWORDS                                   "
    echo "============================================================================"
    echo "ALL PASSWORDS EXCEPT ROOT AND MAIN USER WILL BE CHANGED TO [Cyb3rPatr!0t$]"
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

#password Policy-6
psswdPolicy() {
    apt-get install libpam-cracklib -yq >> ScriptLogs
    #git clone https://github.com/Th3-0/things-for-things.git
    cd things-for-things/ConfigFiles
    #common-password
    sudo cp /etc/pam.d/common-password /etc/pam.d/common-passwordOLD
    sudo chmod 640 common-password
    sudo chown root:root common-password
    sudo cp -f common-password /etc/pam.d/common-password
    #common-auth
    sudo mv /etc/pam.d/common-auth /etc/pam.d/common-authOLD
    sudo chmod 640 common-auth
    sudo chown root:root common-auth
    sudo cp -f common-auth /etc/pam.d/common-auth
    #login.defs
    sudo mv /etc/login.defs /etc/login.defsOLD
    sudo chmod 640 login.defs
    sudo chown root:root login.defs
    sudo cp -f login.defs /etc/pam.d/login.defs

    Confirmation
}

#securing perms-8
perms() {
    chmod 640 /etc/shadow
    Confirmation
}

#badPrograms-9
badPrograms() {
    echo "programs to look into deleting"
    echo "all output will be entered into investigate.txt file in home dir."

    read -p "Please enter main CyberPatriots user" user
    #insert thing to specify different keyword files
    read -p "enter the path of the keyword file:" KeywordsFile
    if [ $KeywordsFile =="" ];
    then
    KeywordsFile="PPKeywords.txt"
    fi 

    mapfile Keywords < $KeywordsFile
    dpkg -l | awk '{print $2}' > /home/$user/keywords.temp
    for (( i=0; i<${#Keywords[@]}; i++ ));
    do #fix this clusterfuck at some point
    grep ${Keywords[i]} /home/$user/keywords.temp >> /home/$user/ProgramsToCheck #keep here as backup
    done
    clear
    end_question () {
    echo "Do you want to filter further? "
    select answer in "Yes" "No" "CheckCurrent"; do
    case $answer in
        Yes ) break;;
        No ) echo "Exiting..."; exit;;
        CheckCurrent ) 
        clear;
        echo "========================="; 
        cat /home/$user/ProgramsToCheck; 
        echo "========================="; 
        end_question;;
    esac
    done
    }
    end_question

    read -p "Enter other filters in {filter}|{filter} format(do not includ {}) COMMON EX: lib|driver:" SecondaryFilters
    #really fucking stupid-ill fix eventually
    grep -Ev $SecondaryFilters /home/$user/ProgramsToCheck >> ProgramsToCheck1
    rm ProgramsToCheck | mv ProgramsToCheck1 ProgramsToCheck
    end_question
    Confirmation
}

#ssh-7
ssh() {
    echo "not yet available"
    Confirmation
}

#all-11
all() {
    firewall
    badFiles
    rootDisable
    psswdPolicy
    passwrds
    perms
    clamav
    Confirmation
}

Confirmation() {
    read -p "type c when you want to continue: " hi
    if [ $hi == "c" ]
    then
        Run
    fi
}
Run



 
