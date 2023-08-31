#-------------------------------------------------------------------------------
# Sensible setup
set -o vi
set -o physical
set t_Co=256
[[ $- == *i* ]] && stty sane
umask 002
alias ssh='ssh -Y'
alias c='clear'
alias memuse='ps aux --sort=pmem,-rss |head -n 10|cut -c1-100'
alias tkdiff='tkdiff -w -B'
alias diff='diff -b'
alias b='cd -'
alias ls='ls -Fs --color=auto'
alias cp='\cp -f'
alias mv='\mv -f'
alias rm='\rm -f'
alias pkill='\pkill -f'
alias top='\top -u $USER -d 1'
alias h='history | tail -n 60'
alias k='kill -9 %1'
alias ping='ping -c 4'
alias grep='grep --color=auto'
alias mkdir='\mkdir -pv'
alias wget='wget -c'
alias trim="sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g'"
alias head='head -n $((${LINES:-12}-2))'
alias tail='tail -n $((${LINES:-12}-2))'
alias vi='vim -p'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias ipup="ifconfig $(ip -br addr show 2> /dev/null | grep UP|awk '{print $1}')"
alias upip="echo $(hostname -I 2> /dev/null | awk '{print $1}')"
alias macip="echo $(ifconfig ppp0 2> /dev/null | grep inet | awk '{print $2}')"
alias a64regs="command du -a ~/aarch64_regs | grep '\.html$'| grep 2023 | grep -v diff-from |  grep -v AArch32 | awk '{print \$2}'|fzf|xargs -r firefox"
alias .='cd ../'
alias ..='cd ../../'
alias ...='cd ../../../'
alias .3='cd ../../../'
alias ....='cd ../../../../'
alias .4='cd ../../../../'
alias .....='cd ../../../../../'
alias .5='cd ../../../../../'
alias ......='cd ../../../../../../'
alias .6='cd ../../../../../../'
if [[ -n "$BASH_VERSION" ]]; then
   shopt -s cdspell
   shopt -s histappend
   shopt -s cdable_vars
   shopt -s autocd
   shopt -s direxpand
fi
export EDITOR=vim
export IGNOREEOF=1
export HISTCONTROL="erasedups:ignoreboth"
export HISTSIZE=1000000
export HISTFILESIZE=1000000000
export HISTIGNORE='pwd:exit:fg:bg:top:clear:history:ls:ll:uptime:df'
export CDPATH=.:
