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

LIT:
   This keyword is used to directly send words and other characters
   to the prompt. This can also be used to send commands into the
   prompt directly without using the keywords, or even use commands
   that have not been implemented yet. NOTE - there is a bug in the
   script that makes backslashes '\\' not be interpreted correctly.
   If using a backslash with the 'LIT' command, please use two in a
   row.

   input: LIT:Hello there!
   output: Hello there!

space
   This keyword is used to insert a single blank space into the
   prompt. This cannot be done with the 'LIT' key word because a
   space is seen as a separator by awk. This is only for when there
   is a single space needed. If it is going to be followed by a
   string, the 'LIT' command will work.

   input: space
   output: (space character)

GIT:
   This is a "base" key word that is used to call other key words.
   In this case, it is used to call commands that have to do with
   the program 'git'.

   cur branch
      This key word is used in conjunction with the 'GIT:' keyword
      and is used to display the current branch that the user is
      in for the current git repo.

      input: GIT:cur branch
      output: Master (or whatever branch is currently active)

   status
      Display the current status of the active git repo, this is the
      equivalent command of 'git status --porcelain'.

      input: GIT:status
      output: file1 -> file2

EXE:
   This key word is designed to run a certain command in the prompt.
   The command can be any bash command, but be careful what it is,
   because it will be run overtime.

   input: EXE:echo "Hello!"
   output: Hello!

COLOR:
   This key word is the one to change the color of all of the text
   after it is called. This call will be followed by the style of
   the font and then the color. For example, 'COLOR:normal,blue'

   normal
      This setting will make the text appear in the standard format.
      This is useful for the ending of the prompt to set the regular
      text back to a standard font style.

   bold
      This is fairly self-explanitory, it is just bold.

   underline
      Make the following text underlined.

   background
      This option will highlight the background around the text.

   Terminal Colors
      The color that you want the font to be fill come after the
      style choice like in the example above. The colors available
      are: black, red, green, yellow, blue, purple, cyan, and white.
      Prefixing one of these with 'light-' will give you the bright
      or light version of that color, example 'COLOR:bold,light-red'
date
   Print out the current date into the prompt.

   input: date
   output: Mon Mar 30 08:02:59 EDT 2015

host
   Adds the name of the machine that the user is currently logged into.
   Alternative names for this are 'computername' and 'machine'.

   input: host
   output: nic-linux-work

job
   This key word will display the current number of jobs managed by
   the current shell.

   input: job
   output:
