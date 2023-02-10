PS1='\[\e[33m\]\u\[\e[37m\]@\[\e[36m\]\h\[\e[37m\]:\W `if [ $? = 0 ]; then echo \[\e[32m\]:\)\[\e[37m\]; else echo \[\e[31m\]:\(\[\e[37m\]; fi` '

# not sure what this does, but it allows C-S
# to search forward on reverse search.
stty -ixon

export CPATH="/usr/local/include/:$CPATH"
export PATH="$HOME/.local/bin/:$PATH"

# blinking bar for xterm
echo -e -n "\x1b[\x35 q"
