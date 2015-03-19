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
    echo "USAGE: setprompt [-h or --help] [NAME OF PROMPT]"
    echo "The name of the prompt should be the first item of each line"
    echo "in the $storage/prompt file."
}

#Use the variable 'optnum' to cycle through the different options given in the script.
#'optnum' should be initially be set to the value of '1', this way when it is used
#as '!optnum' bash will see it as '$1'. The while loop will keep going until the
#option or argument given is blank.
optnum=1
while [ "${!optnum}" != "" ]
do
    case "${!optnum}" in
    "-h")
        print_help
        ;;
    "--help")
        print_help
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

totallines=`cat $storage/prompts | wc -l`
for i in `seq 1 $totallines`
do
    #Use awk to grab the first item, the name, from the line.
    name=`head -$i $storage/prompts | tail -1 | awk -F ';;;' '{print $1}'`
    if [ "$name" == "${!optnum}" ]; then
        matchnum=$(($matchnum+1))
        line=$i
    fi
done

if [ "$matchnum" != "1" ]; then
    echo "ERROR: There are $matchnum lines that match the name ${!optnum}."
    exit 1
fi

#Get the line from the 'prompts' file that matches the name, and begin to set the
#PS1 variable to it. Until finished, this info will be stored in a file called
#'tmp' in the '$storage' directory.
for i in `head -$line $storage/prompts | tail-1 | sed s/";;;"/"\n"/g`
do
    case $i in
    ""