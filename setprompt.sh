#!/bin/bash

#Set variables for where the files and the folders are located so that
#it can be easily changed if needed.
storage="$HOME/.stored_prompts"
convert=changethislocation


#Make a function to output the help options
print_help()
{
    echo "USAGE: setprompt [-h or --help] [-c or --convert] [-l or --list] [NAME OF PROMPT]"
    echo ""
    echo "  -h/--help               Display this help printout."
    echo ""
    echo "  -l/--list               This will show the names of the different"
    echo "                          prompts that are in the conv_prompt file."
    echo ""
    echo "  -c/--convert            Using this with no options will make"
    echo "                          this script convert the 'prompts' file"
    echo "                          into a useable 'PS1' variable."
    echo ""
    echo "The name of the prompt should be the first item of each line"
    echo "in the $storage/prompt file."
    echo ""
}

#Make a function to list the names of all of the prompts.
list_names()
{
    #Check if the 'conv_prompt' file exists. If not tell the user to run
    #the script with -c or --convert to make one.
    if [ ! -e $storage/conv_prompt ]; then
        echo "The 'conv_promt' file that contains the prompts does not"
        echo "exist. Re-run this with the flag '-c' or '--convert' to"
        echo "convert the 'prompts' file into the 'conv_promt' file."
        return 3
    fi

    #Go through the file and display every name
    totallines=`cat $storage/conv_prompt | wc -l`
    for i in `seq 1 $totallines`
    do
        head -$i $storage/conv_prompt | tail -1 | awk -F ';;;' '{print $1}'
    done
    return 0
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
        return 0
        ;;
    #Tell the script to convert the syntax of the 'prompts' file into an actual
    #PS1 prompt that will be stored in 'conv_prompt'
    "-c"|"--convert")
        /usr/local/bin/promptconvert.sh
        return 0
        ;;
    "-l"|"--list")
        list_names
        return 0
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

totallines=`cat $storage/conv_prompt | wc -l`
for i in `seq 1 $totallines`
do
    #Use awk to grab the first item, the name, from the line.
    name=`head -n $i $storage/conv_prompt | tail -n 1 | awk -F ';;;' '{print $1}'`
    if [ "$name" == "${!optnum}" ]; then
        matchnum=$(($matchnum+1))
        line=$i
    fi
done

if [ "$matchnum" != "1" ]; then
    echo "ERROR: There are $matchnum lines that match the name ${!optnum}."
    return 1
else
    PS1=`head -n $line $storage/conv_prompt | tail -n 1 | awk -F ';;;' '{print $2}'`
    export PS1
    echo $PS1
fi
#exit
return 0
