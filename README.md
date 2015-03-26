# set_prompt
Be able to dynamically change the bash prompt (PS1 variable) to
something more useful to the user depending on what they are doing.

  Most of the time a person would just use one prompt for the entire
terminal session. The point of this script is to be able to change
the prompt of a UNIX/Linux terminal to something more useful to the
user, and be able to do so easily.

  The different prompts will actually be stored in a file in the
user's home directory, and can be changed or expanded to fit the
user's needs. This script should not just set the PS1 variable from
a file, but also provide some tools to make the creation of prompts
easier to understand and do without constantly looking up the syntax.

#Installation

  To install the script simply run the install script as an admin
or root. This will take care of just about everything for you. The
install script will by default install to /usr/local/bin if you would
like to change this directory then say so in the top portion of the
install script by changing the value of the 'loc' variable.

  On the first run of the script, it will check the user's home
directory for the folder '~/.stored_prompts'. If the directory is
missing, it will create one for you and place the 'sample_prompts'
file in that location, renaming it to 'prompts'. If this file is not
in the same folder as the 'setprompt' file, then it will just place
a blank file in it's place.

#customizing the Prompts

  To make the different prompts, and to make them easier to write
there is a file in the ~/.stored_prompts folder called 'prompts'.
This file holds the outline for each prompt that is written in a
certain notation to be read by the script, take a look at the
'sample_prompts' file for an example. Each part of the 'prompts'
file is separated by three semicolons ';;;'. This is the delimiter
that tells the script where to separate the entries, so please try
to avoid using that string of characters in the prompt.

   There are several key words that can be used to make the prompts
easily. More will be added depending on complexity and demand.

The current key words are:
