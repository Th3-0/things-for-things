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
    read -p "Please list all Admin Users: " adminanswer
    if [$adminanswer == "done."] then return fi
    NeededUsers+=($adminanswer)
    NeededUsers
}

