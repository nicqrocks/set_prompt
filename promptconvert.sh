#!/bin/bash

#Get the line from the 'prompts' file that matches the name, and begin to set the
#PS1 variable to it. This will be stored in a file called 'conv_prompt' in the
#current storage directory.
#Check if the 'conv_prompts' file currently exists. If it does,
#make a backup of it and tell the user that it will re-created
storage="$HOME/.stored_prompts"


if [ ! -e $storage/conv_prompt ]; then
    echo "Making 'conv_prompt' file in $storage..."
    touch $storage/conv_prompt
else
    echo "The 'conv_prompt' file currently exists. This one will have a"
    echo "backup made of it. WARNING THIS WILL OVERWRITE A PREVIOUS"
    echo "BACKUP IF IT EXISTS. Are you sure you want to continue?"
    echo "yes / no"
    read answer
    #Check if $answer is 'yes' or 'no'
    while [ "$answer" != "yes" ] && [ "$answer" != "no" ]; do
        smoothOut "Please choose only 'yes' or 'no' as the answer."
        read answer
    done
    if [ "$answer" == "yes" ]; then
        echo "Backing up the file..."
        mv $storage/conv_prompt $storage/conv_prompt.bak
        sleep 1
        touch $storage/conv_prompt
    else
        echo "Exiting..."
        exit 1
    fi
fi

echo "Converting the file to something that the PS1 variable can use..."

#Make a function to append to the file easier.
appendfile()
{
    echo -n "$1" >> $storage/conv_prompt
}

#Cycle through the 'prompts' file one line at a time, skipping any that
#begin with a '#'.
counter=0
while read line ;
#for line in `cat $storage/prompts`
do
    counter=$(($counter+1))

    if [[ $line =~ ^\# ]] || [[ "$line" == "" ]]; then
        echo "Skipping line $counter..."
        continue
    fi
    echo "Reading line $counter..."
    #Add name of the prompt to the beginning of the line.
    name=`echo $line | awk -F ';;;' '{print $1}'`
    echo $name
    appendfile "$name;;;"
    #Loop through the different fields
    echo $line | sed s/";;;"/"\n"/g | while read i ;
    do
        echo "Item = $i"
        args=`echo $i | cut -d ':' -f 2-`
        case $i in
        #Write out exactly what the user wants. This feature is useful
        #when a shortcut for a certain command does not exist.
        "LIT:"*)
            appendfile "$args"
            ;;
         #Add a blank space to the prompt line. The LIT feature
         #does not handle a blank space well.
         "space"|"Space")
            appendfile ' '
            ;;
        #Git repo integration and commands
        "GIT:"*)
            case "$args" in
            #Return the name of the current branch
            "cur"*"branch")
                appendfile '$(git rev-parse --abbrev-ref HEAD)'
                ;;
            #Return the current status of the current repository
            "stat"*)
                appendfile '$(git status -s)'
                ;;
            esac
            ;;
        #Execute a string of commands prefixed by 'EXE:'
        "EXE:"*)
            appendfile "$(`echo $i | cut -d ':' -f 2-`)"
            ;;
        #Determine what to change the color to
        "COLOR:"*)
            style=`echo $args | cut -d ',' -f 1`
            case $style in
            "normal"|"Normal")
                appendfile '\[\e[0;'
                ;;
            "bold"|"Bold")
                appendfile '\[\e[1;'
                ;;
            "underline"|"Underline")
                appendfile '\[\e[4;'
                ;;
            "background"|"Background")
                appendfile '\[\e['
                ;;
            *)
                echo "ERROR: $i not understood."
                echo "This error was found in a 'COLOR:style' declaration."
                echo "Valid options for style: bold, normal, underline, and background."
                exit 2
                ;;
            esac
            colors=`echo $args | cut -d ',' -f 2`
            case $colors in
            "black"|"Black")
                appendfile '30m\]'
                ;;
            "light-black"|"Light-Black")
                appendfile '90m\]'
                ;;
            "red"|"Red")
                appendfile '31m\]'
                ;;
            "light-red"|"Light-Red")
                appendfile '91m\]'
                ;;
            "green"|"Green")
                appendfile '32m\]'
                ;;
            "light-green"|"Light-Green")
                appendfile '92m\]'
                ;;
            "yellow"|"Yellow")
                appendfile '33m\]'
                ;;
            "light-yellow"|"Light-Yellow")
                appendfile '93m\]'
                ;;
            "blue"|"Blue")
                appendfile '34m\]'
                ;;
            "light-blue"|"Light-Blue")
                appendfile '94m\]'
                ;;
            "purple"|"Purple")
                appendfile '35m\]'
                ;;
            "light-purple"|"Light-Purple")
                appendfile '95m\]'
                ;;
            "cyan"|"Cyan")
                appendfile '36m\]'
                ;;
            "light-cyan"|"Light-Cyan")
                appendfile '96m\]'
                ;;
            "white"|"White")
                appendfile '37m\]'
                ;;
            "light-white"|"Light-White")
                appendfile '97m\]'
                ;;
            *)
                echo "ERROR: $i not understood."
                echo "This error was found in a 'COLOR:colors' declaration."
                echo "Valid options for style: black, red, green, yellow, blue,"
                echo "purple, cyan, and white. Prefixing one of these with"
                echo "'light-' will give you the bright or light version of"
                echo "that color."
                exit 2
                ;;
            esac
            ;;
        #Get the Date
        "date"|"Date")
            appendfile '\d'
            ;;
        #Get the name of the computer
        "host"*|"machine"|"computername"|"Host"*|"Machine"|"Computername")
            appendfile '\h'
            ;;
        #Get the number of jobs
        "job"*|"Job"*)
            appendfile '\j'
            ;;
        #Shell terminal device basename
        "shell-basename"|"Shell-Basename")
            appendfile '\l'
            ;;
        #What kind of shell is running
        "shell"|"Shell"|"shellname"|"Shellname")
            appendfile '\s'
            ;;
        #Time
        "TIME:"*)
            case $type in
            #24 hour time
            "24")
                appendfile '\t'
                ;;
            #12 hour time
            "12")
                appendfile '\T'
                ;;
            #standard 12 hour time with am/pm
            "norm"*|"stan"*|"Norm"*|"Stan"*)
                appendfile '\@'
                ;;
            *)
                echo "ERROR: $i not understood."
                echo "This error was found in a 'time' declaration."
                echo "Valid options for time: 24, 12, normal"
                exit 2
                ;;
            esac
            ;;
        #Get the username
        "user"*|"User"*)
            appendfile '\u'
            ;;
        #Bash version
        "ver"*|"Ver"*)
            appendfile '\v'
            ;;
        #Current directory
        "curdir"|"Curdir"|"current directory"|"Current Directory")
            appendfile '\w'
            ;;
        "where"*"am"*"i"|"Where"*"am"*"i")
            appendfile '\W'
            ;;
        #Return the history number
        "hist"*|"Hist"*)
            appendfile '\!'
            ;;
        #Write the command number
        "com"*"num"*|"Com"*"num"*)
            appendfile '\#'
            ;;
        #Check if the user is root
        "check"*"root"|"Check"*"Root")
            appendfile '\$'
            ;;
        #Add a newline
        "new"*"line"|"New"*"Line"|"New"*"line")
            appendfile '\n'
            ;;
        #Add an escape character
        "esc"*|"Esc"*)
            appendfile '\e'
            ;;
        #bell
        "bell"|"Bell")
            appendfile '\a'
            ;;
        *)
            echo "Entry $i not understood. If this item is the name,"
            echo "then ignore this error. Otherwise, please take another"
            echo "look at your 'prompts' file."
            ;;
        esac
    done

    #Add a blank line at the end of the cycle, so that the prompts do not
    #interfere with each other.
    echo "" >> $storage/conv_prompt
done < $storage/prompts

#Conversion into a prompt should be complete, tell the user
echo "The conversion is complete. The different prompts can"
echo "be called by using the name as an argument at any time."
exit 0
