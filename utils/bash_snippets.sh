BOLD="$(tput bold 2>/dev/null || printf '')"
BLACK="$(tput setaf 240 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
CYAN="$(tput setaf 6 2>/dev/null || printf '')"
WHITE="$(tput setaf 7 2>/dev/null || printf '')"
GRAY="$(tput setaf 8 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"
export BAT_THEME=gruvbox-dark
function printne() {
   color=$1
   str="${@:2}"
   printf "${!color}$str$NO_COLOR"
}
function print() {
   color=$1
   str="${@:2}"
   printf "${!color}$str$NO_COLOR\n"
}
function info() {
   printf '%s\n' "$BOLD$WHITE> $@$NO_COLOR"
}
function warn() {
   printf '%s\n' "$YELLOW! $@$NO_COLOR"
}
function error() {
   printf '%s\n' "${RED}x $@$NO_COLOR" >&2
}
function completed() {
   printf '%s\n' "$GREEN✓ $@$NO_COLOR"
}
function print_sequence() {
   binary_sequence="$1"
   group_size="${2:-4}"

   # Pad the sequence with zeros to the left with a multiple of 4
   if [[ $((${#binary_sequence}%${group_size}))  != 0 ]]; then
      padded_sequence=$(printf "%0$((${group_size} - ${#binary_sequence} % ${group_size}))d%s" 0 "$binary_sequence")
   else
      padded_sequence=$binary_sequence
   fi

   # Set the colors
   color1=$RED
   color2=$BLUE
   resetc=$NO_COLOR
   # Loop through the padded sequence
   for ((i = 0; i < ${#padded_sequence}; i++)); do
      # Get the current binary digit
      digit="${padded_sequence:i:1}"

      # Set the color based on the index
      if ((i % $(($group_size * 2)) < $group_size)); then
         color="$color1"
      else
         color="$color2"
      fi

      # Print the digit with the appropriate color
      echo -ne "${color}${digit}${resetc}"
   done
   echo
}
function var () {
   VAR=${1:-PATH}
   DOLLARVAR=${!VAR}
   echo -e ${DOLLARVAR//:/\\n}
}
function has() {
   command -v "$1" 1>/dev/null 2>&1
}
function Pushd() {
   command pushd "$@" >/dev/null 2>&1
}
function Popd() {
   command popd >/dev/null 2>&1
}
function xpushd () {
   dir=${1:-.}
   cd $dir
   echo "pushing: $proj/.x_push_pop_stack"
   mkdir -p $proj
   echo "$PWD" > "$proj/.x_push_pop_stack"
}
function xpopd () {
   echo "popping: $proj/.x_push_pop_stack"
   if [[ -f $proj/.x_push_pop_stack ]]; then
      cd $(command cat "$proj/.x_push_pop_stack")
   else
      echo "Note: xpushd first"
   fi
}
function tempfile() {
   mkdir -p /tmp/$USER
   if has mktemp; then
      printf "%s" "$(mktemp -p /tmp/$USER)"
   else
      printf "/tmp/$USER/tmp.$(date +%H_%M_%S)"
   fi
}
function timestamp() {
   if [[ $1 == "start" ]]; then
      time_duration=$(date +%s)
   else
      time_duration=$(( $(date +%s) - $time_duration ))
      echo "$(date -d@${time_duration} -u  +%H:%M:%S) H:M:S"
   fi
}

function download() {
   url="$1"
   file="${url##*/}"

   if has curl; then
      cmd="curl --fail --silent --location --output $file $url"
   elif has wget; then
      cmd="wget --quiet --output-document=$file $url"
   elif has fetch; then
      cmd="fetch --quiet --output=$file $url"
   else
      error "No HTTP download program (curl, wget, fetch) found, exiting…"
      return 1
   fi

   $cmd && return 0 || rc=$?

   error "Command failed (exit code $rc): ${BLUE}${cmd}${NO_COLOR}"
   return $rc
}
function wget4me() {
   urltype=$1
   url=$2

   if [[ $urltype == "tar" ]]; then
      tarfile=$(basename $url)
      if [[ ! -e $tarfile ]]; then
         echo "Info: wgetting $url"
         wget $url --no-check-certificate > $tarfile.wget.log 2>&1
         echo "Info: expanding $tarfile"
         tar -xvf $tarfile > $tarfile.tar.log 2>&1
      fi
   fi
}
function latest_file() {
   pat=$1
   command fd -td $pat --max-depth=2 --exec stat --printf='%Y\t%n\n'|sort -nr|head -n1|cut -f2
}
function ifont() {
   # Install font
   echo "Note: Installing FiraCode font"
   mkdir -p ~/.fonts && pushd ~/.fonts >> /dev/null
   wget --no-verbose https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip -O /tmp/FiraCode.zip 2>/dev/null
   unzip -q /tmp/FiraCode.zip
   popd >> /dev/null
   # Now set font@gnome-terminal
   GNOME_TERMINAL_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}')
   gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font 'FiraCode Nerd Font Mono 12'
}
function xvim() {
   dbus-launch gnome-terminal --title="gvim: $@" --hide-menubar --geometry=130x50 -- vim "$@" >/dev/null
}
function duration() {
   local seconds=$1

   local formatted_time=$(date -u -d @${seconds} +"%Hh %Mm %Ss")
   echo "${formatted_time}"
}
#-------------------------------------------------------------------------------
# Note: clip from gvim
# My workaround for not having xsel or xclip
#   Ex: clipboard=$( get_clip )
function get_clip() {
   mkdir -p /tmp/$USER
   file=/tmp/$USER/clipboard_contents.txt
   /bin/rm -f $file
   # Help from:  http://stackoverflow.com/a/23237529/120681
   command gvim $file -T dumb --noplugin -n -es -c 'set nomore' +'normal "*P' +'wq'
   cat $file
}
function modpath () {
   loc=$1
   cmd=${2:-"d"}
   var=${3:-PATH}
   eval PATHv=\$$var    # set PATHv to the var reference (double indirection)
   NEW_PATH=${PATHv/#"$loc:"}         #    Begining
   NEW_PATH=${NEW_PATH/#"$loc"}       #    Solo
   NEW_PATH=${NEW_PATH/%":$loc"}      #    Ending
   NEW_PATH=${NEW_PATH//":$loc:"/:}   #    Multiple middles

   if [ $cmd = "d" ]; then
      export ${var}=$NEW_PATH
   elif [ $cmd = "b" ]; then
      if [ -z $NEW_PATH ]; then
         export ${var}=$loc   # old PATH empty
      else
         export ${var}=$loc:$NEW_PATH
      fi
   elif [ $cmd = "a" ]; then
      if [ -z $NEW_PATH ]; then
         export ${var}=$loc   # old PATH empty
      else
         export ${var}=$NEW_PATH:$loc
      fi
   else
      echo "usage: modpath [location] [d elete|b efore|a fter] [VARIABLE]"
   fi
}
#-------------------------------------------------------------------------------
function sa() {
   ./pal vcat_exec "$*"
}

