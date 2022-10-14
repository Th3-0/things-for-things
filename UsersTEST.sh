#!/bin/bash

#apt-get install members #don't use members in future
#thought process:
#make list of allowed admin and standard users
#check for unathorized admin users and delete
#check for missing admin users and add
#check for missing standard users and add
#check for users that shouldn't be on system

CurrentUser=$(whoami)
#remove user from sudo group {deluser [user] sudo} - and maybe {deluser [user] admin} on ubuntu idk though
#assign users currently on system to arrays
mapfile -t AllCurrentUsers < <(getent passwd {1000..1500} | cut -d: -f1) 
mapfile -t CurrentAdminUsers < <(members sudo)
mapfile -t CurrentNormUsers < <(echo ${AllCurrentUsers[@]} ${CurrentAdminUsers[@]} | tr ' ' '\n' | sort | uniq -u)

#Comparing Admins
NeededUsers=($CurrentUser)

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
    fi
}
enteradmins

mapfile -t AdminDiffs < <(echo ${CurrentAdminUsers[@]} ${NeededUsers[@]} | tr ' ' '\n' | sort | uniq -u)

for (( i=0; i<${#AdminDiffs[@]}; i++ ));
do
    if [[ " ${NeededUsers[*]} " =~ " ${AdminDiffs[i]} " ]]
    then #if user is on README but not currently admin
        if [[ " ${CurrentNormUsers[@]} " =~ " ${AdminDiffs[i]}"]] 
        then # user is a standard user that needs to be upgraded
            echo "change standard user ${AdminDiffs[i]} to admin"
        elif [[ ! " ${CurrentNormUsers[@]} " =~ " ${AdminDiffs[i]}"]]
        then # user is not present on system
            echo "add admin user ${AdminDiffs[i]}"
        fi
    elif [[ ! " ${NeededUsers[*]} " =~ " ${AdminDiffs[i]} " ]]
    then #user is on system but not readme
        echo "delete user ${AdminDiffs[i]}"
    fi
        
    

