#!/bin/bash -
#title           :ProhibitedPrograms.sh
#description     :Will use keywords to find hacking/prohibited programs(not malware)
#author          :Th3-0
#version         :0.1
#usage           :"bash ProhibitedPrograms.sh" or "./ProhibitedPrograms.sh"
#==========================================================================================
echo "programs to look into deleting"
echo "all output will be entered into investigate.txt file in home dir."

user=$(whoami)
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
   grep ${Keywords[i]} /home/$user/keywords.temp > /home/$user/ProgramsToCheck #keep here as backup
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
grep -Ev $SecondaryFilters /home/$user/ProgramsToCheck > ProgramsToCheck1
rm ProgramsToCheck |  && mv ProgramsToCheck1 ProgramsToCheck
end_question
