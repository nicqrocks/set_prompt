#!/bin/bash

#set variables so that things can be changed easily.
#Install location that can be found in $PATH:
loc='/usr/local/bin'
echo "Install location set to $loc"
#Sleep 2 seconds just in case.
sleep 2

#Check if the user running this script is root or admin
usr=`whoami`
if [ "$usr" != "root" ] && [ "$usr" != "admin" ]; then
    echo "Running script as `whoami`"
    echo "Please run this script as an administrator or root."
    exit 1
fi

#Check if the preference directory exists. This will be the location
#that the different prompts are stored in, along with everything else.
if [ ! -d $storage ]; then
    if [ ! -e $storage ]; then
        echo "The '~/.stored_prompts' directory does not exist. Creating a new one..."
        mkdir $storage
        echo "Moving the 'sample_prompts' file into that location..."
        if [ -e sample_prompts ]; then
            cp sample_prompts $storage/prompts
        else
            echo "'sample_prompts' file missing, making blank prompts file instead..."
            echo "Remember to code the prompts into here."
            touch $storage/prompts
        fi
    else
        echo "The '~/.stored_prompts' file should be a directory, not a file."
        echo "If you remove it and run this again, it will make the directory"
        echo "and make a 'prompts' file in there for you."
        exit 2
    fi
fi

#Set the permissions for the scripts so that all users can use them
echo "Setting permissions..."
chmod 755 setprompt.sh promptconvert.sh

#Change where the 'setprompt.sh' is going to call the 'promptconvert.sh'
#file from. This make it so it can be installed anywhere, not just the path
echo "Changing where the 'setprompt.sh' file looks for the"
echo "'promptconvert.sh' file."
sed -i "s/changethislocation/$loc/g" setprompt.sh

#Move the scripts to the install location.
echo "Moving 'setprompt.sh' to $loc/setprompt..."
cp setprompt.sh $loc/setprompt.sh
echo "Moving 'promptconvert.sh' to $loc/promptconvert.sh..."
cp promptconvert.sh $loc/promptconvert.sh

#Add an alias in an alias file or something like '.bashrc' that will make the
#script run in the current shell, not a new one using the '.' command.

for file in `ls -a $HOME`
do
   case "$file" in
   ".alias")
      aliasfile="$HOME/.alias"
      found=true
      break
      ;;
   ".bash_profile")
      aliasfile="$HOME/.bash_profile"
      found=true
      break
      ;;
   ".bash_login")
      aliasfile="$HOME/.bash_login"
      found=true
      break
      ;;
   ".bashrc")
      aliasfile="$HOME/.bashrc"
      found=true
      break
      ;;
   ".profile")
      aliasfile="$HOME/.profile"
      found=true
      break
      ;;
   *)
      found=false
      ;;
   esac
done

if [ $found == false ]; then
   echo "A suitable file to place the alias was not found."
   echo "Please specify the full path to a location you want"
   echo "the files to be installed to."
   read aliasfile
fi

echo "Adding alias to $aliasfile..."
echo "" >>$aliasfile
echo "#Add an alias to run the 'setprompt' script in the current shell." >>$aliasfile
echo "alias setprompt='. $loc/setprompt.sh'" >>$aliasfile

#Done
echo "Done"
exit 0
