#!/bin/bash

#Begin by checking if the preference directory exists. This file will be the location
#that the different prompts are stored in.
storage="$HOME/.stored_prompts"

if [ ! -d $storage ]; then
    if [ ! -e $storage ]; then
        echo "The '~/.stored_prompts' directory does not exist. Creating a new one..."
        mkdir $storage
        echo "Moving the sample prompts file into that location..."
        if [ -e sample_prompts ]; then
            mv sample_prompts $storage/prompts
        else
            echo "'sample_prompts' file missing, making blank prompts file instead..."
            touch $storage/prompts
        fi
    else
        echo "The '~/.stored_prompts' file should be a directory, not a file."
        echo "If you remove it and run this again, it will make the directory"
        echo "and make a 'prompts' file in there for you."
    fi
fi



#Make a function to output the help options
print_help()
{
    echo "USAGE: setprompt [-h or --help] [-c or --convert] [NAME OF PROMPT]"
    echo ""
    echo "  -h/--help               Display this help printout."
    echo "  -c/--convert            Using this with no options will make"
    echo "                          this script convert the 'prompts' file"
    echo "                          into a useable 'PS1' variable."
    echo ""
    echo "The name of the prompt should be the first item of each line"
    echo "in the $storage/prompt file."
    exit 0
}



#Use the variable 'optnum' to cycle through the different options given in the script.
#'optnum' should be initially be set to the value of '1', this way when it is used
#as '!optnum' bash will see it as '$1'. The while loop will keep going until the
#option or argument given is blank.
optnum=1
while [ "${!optnum}" != "" ]
do
    case "${!optnum}" in
    #print out the help options
    "-h"|"--help")
        print_help
        ;;
    #Tell the script to convert the syntax of the 'prompts' file into an actual
    #PS1 prompt that will be stored in 'conv_prompt'
    "-c"|"--convert")
        convert
        ;;
    esac
#add one to 'optnum'
optnum=$(($optnum+1))
done



#Once this has completed, take one away from the 'optnum' variable. This will give
#the name of the prompt that the user wants to use. Once this is done, search the
#'prompts' file for one that matches it, but make sure that there is only one match.
optnum=$(($optnum-1))
matchnum=0

totallines=`cat $storage/conv_prompts | wc -l`
for i in `seq 1 $totallines`
do
    #Use awk to grab the first item, the name, from the line.
    name=`head -$i $storage/conv_prompts | tail -1 | awk -F ';;;' '{print $1}'`
    if [ "$name" == "${!optnum}" ]; then
        matchnum=$(($matchnum+1))
        line=$i
    fi
done

if [ "$matchnum" != "1" ]; then
    echo "ERROR: There are $matchnum lines that match the name ${!optnum}."
    exit 1
else
    PS1=`head -$line $storage/conv_prompt | tail -1`
fi
#exit
exit 0


#Get the line from the 'prompts' file that matches the name, and begin to set the
#PS1 variable to it. This will be stored in a file called 'conv_prompt' in the
#current storage directory.
convert()
{
    #Check if the 'conv_prompts' file currently exists. If it does,
    #make a backup of it and tell the user that it will re-created
    if [ ! -e $storage/conv_promt ]; then
        echo "Making 'conv_prompt' file in $storage"
        touch $storage/conv_prompt
    else
        echo "The 'conv_prompt' file currently exists. This one will have a"
        echo "backup made of it. WARNING THIS WILL OVERWRITE A PREVIOUS"
        echo "BACKUP IF IT EXISTS. There will be a 10 second delay before the"
        echo "backup happens, use this time to kill the current process with"
        echo "control-c and decide what to do with the file."
        sleep 11
        echo "Backing up the file..."
        mv $storage/conv_prompt $storage/conv_prompt.bak
        sleep 1
        touch $storage/conv_prompt
    fi
    
    #Cycle through the 'prompts' file one line at a time, skipping any that
    #begin with a '#'.
    for line in `cat $storage/prompts | wc -l`
    do
        #Make a function to append to the file easier.
        appendfile()
        {
            echo -n "$1" >> $storage/conv_prompt
        }
        #Add name of the prompt to the beginning of the line.
        name=`head -$i $storage/prompts | tail -1 | awk -F ';;;' '{print $1}'`
        appendfile "$name"
        #Loop through the different fields
        for i in `head -$line $storage/prompts | tail-1 | sed s/";;;"/"\n"/g`
        do
            args=`echo $i | cut -d ':' -f 2-`
            case $i in
            #Write out exactly what the user wants. This feature is useful
            #when a shortcut for a certain command does not exist.
            "LIT:"*)
                appendfile "$args"
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
    done
    
    #Conversion into a prompt should be complete, tell the user
    echo "The conversion is complete. The different prompts can"
    echo "be called by using the name as an argument at any time."
    exit 0
}