#-------------------------------------------------------------------------------
alias ssh='ssh -Y'
alias c='clear'
alias tkdiff='tkdiff -w -B'
alias diff='diff -b'
alias b='cd -'
alias ls='ls -Fs --color=auto'
alias cp='\cp -f'
alias mv='\mv -f'
alias rm='\rm -f'
alias pkill='\pkill -f'
alias top='\top -u $USER -d 1'
# h(): promoted to a function in utils/bash_utils.sh (does two things:
# pulls sibling-shell additions via `history -n`, then prints the tail).
alias k='kill -9 %1'
alias ping='ping -c 4'
alias grep='grep --color=auto'
alias mkdir='\mkdir -pv'
alias wget='wget -c'
alias trim="sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g'"
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias ipup="ifconfig $(ip -br addr show 2> /dev/null | grep UP|awk '{print $1}')"
alias upip="echo $(hostname -I 2> /dev/null | awk '{print $1}')"
alias macip="echo $(ifconfig ppp0 2> /dev/null | grep inet | awk '{print $2}')"
alias dirls="~/aarch64_docs/dirls"
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias ..3='cd ../../../'
alias .....='cd ../../../../'
alias ..4='cd ../../../../'
alias ......='cd ../../../../../'
alias ..5='cd ../../../../../'
alias .......='cd ../../../../../../'
alias ..6='cd ../../../../../../'
alias tree="tree -C -I "__pycache__" -I "obj_dir" -L 4"
