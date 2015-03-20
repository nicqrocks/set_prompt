# set_prompt
Set the prompt (PS1 variable) to what ever is needed at the time.

  Most of the time a person would just use one prompt for the entire
terminal session. The point of this script is to be able to change
the prompt of a UNIX/Linux terminal to something more useful
depending on where the user is and what they are doing.

  The different prompts will actually be stored in a dot file in the
user's home directory, and can be changed or expanded to fit the
user's needs. This script should not just set the PS1 variable from
a file, but also provide some tools to make the creation of prompts
easier to understand.

Installation

  To install this script, please put the contents of the folder into
your path. On the first run of the script, it will check the user's
home directory for the folder '~/.stored_prompts'. If the directory
is missing, it will create one for you and place the 'sample_prompts'
file in that location, renaming it to 'prompts'. If this file is not
in the same folder as the 'setprompt' file, then it will just place
a blank file in it's place.

  Keep in mind that both the 'setprompt' file and the 'promptconvert'
file need to be in the path, otherwise the script will fail. The
following is a sample of how a person would install the script on
a machine. This will use the '/usr/local/bin' directory to store the
script in the user's path. If you do not want it there, change the
'place' variable below to where you want it.

#Open terminal/console and cd into the directory this downloaded to
chmod +x setprompt.sh promptconvert.sh
place='/usr/local/bin'
sudo cp setprompt.sh $place/setpromt
sudo promptconvert.sh $place/promptconvert.sh
sudo sample_prompts $place/sample_prompts
