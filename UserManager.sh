#!/bin/bash
#title           :UserManager.sh
#description     :Checks readme and modifies users as needed
#version         :1.0
#usage           :"sudo bash UserManager.sh" or "sudo ./UserManager.sh"
#================================================================================

CurrentUser=$(whoami)
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

#ype [done.]: " StandardAnswer
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
            echo "change standard user ${AdminDiffs[i]} to admin" > UserChangeLog
        elif [[ ! ${CurrentNormUsers[*]} =~ ${AdminDiffs[i]} ]]
        then # user is not present on system
            useradd -s /bin/bash -m -G sudo ${AdminDiffs[i]}
            echo "add admin user ${AdminDiffs[i]}" > UserChangeLog
        fi
    elif [[ ! ${NeededUsers[*]} =~ ${AdminDiffs[i]} ]]
    then #user is on system but not readme
        if [[  ${NeededStandard[*]} =~ ${AdminDiffs[i]} ]]
        then
            deluser ${AdminDiffs[i]} sudo
            echo "downgrade Admin ${AdminDiffs[i]} to standard" > UserChangeLog 
        else
            userdel -rf ${AdminDiffs[i]}
            echo "remove user ${AdminDiffs[i]}" > UserChangeLog

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
            echo "change admin ${StandardDiffs[i]} to standard user" > UserChangeLog
        elif [[ ! ${CurrentAdminUsers[*]} =~ ${StandardDiffs[i]} ]]
        then # user is not present on system
            useradd -s /bin/bash -m ${StandardDiffs[i]}
            echo "add standard user ${StandardDiffs[i]}" > UserChangeLog
        fi
    elif [[ ! ${NeededStandard[*]} =~ ${StandardDiffs[i]} ]]
    then #user is on system but not Readme
        if [[  ${NeededUsers[*]} =~ ${StandardDiffs[i]} ]]
        then #(again somewhat redundant) user is supposed to be admin
            usermod -aG sudo ${StandardDiffs[i]}
            echo "upgrade standard ${StandardDiffs[i]} to admin" > UserChangeLog
        else #user should not be on machine
            userdel -rf ${StandardDiffs[i]}
            echo "remove user ${StandardDiffs[i]}" > UserChangeLog
        fi
    fi
done
clear
echo "  check UserChangeLog file to find, troubleshoot or review what was edited"
echo "============================================================================"
echo "                                PASSWORDS                                   "
echo "============================================================================"
echo "ALL PASSWORDS EXCEPT ROOT AND MAIN USER WILL BE CHANGED TO [CyberPatri0t$]"
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
        echo "${AllCurrentUsers[i]}:CyberPatri0t$" | chpasswd
    fi
done


