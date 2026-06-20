# bash_snippets.sh -- domain-specific helper functions.
#
# Fundamentals (colors, info/warn/error/completed/print/printne, has, Pushd,
# Popd, download, modpath, var) live in bash_first.sh and are sourced first
# below so anything still loading bash_snippets directly (e.g. daily_build.sh)
# keeps working without changes.
#
# Loader contract:
#   * ~/dotfiles/bash_functions.sh sources bash_first.sh BEFORE the
#     alphabetical bash_*.sh loop and SKIPS bash_snippets.sh in the loop
#     (the historical pattern -- snippets aren't part of the per-shell init).
#   * ~/dotfiles/dotfiles.sh sources bash_first.sh directly for its own
#     install/link output (no longer goes via bash_snippets).
#   * Standalone scripts (e.g. daily_build.sh) can still
#     `source bash_snippets.sh` and get the fundamentals via the back-compat
#     source below.
# shellcheck source=bash_first.sh
source ~/dotfiles/utils/bash_first.sh

# print_sequence BIN_STR [GROUP=4] : binary string in alternating red/blue
# nibble-wide groups. Used for visual debug of bit fields.
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

# xpushd / xpopd : per-process directory-stack persisted to a tempfile under
# ~. Distinct from Pushd/Popd (which use bash's own builtin stack); xpushd
# survives across shells (so you can `xpushd` here, switch terminals, then
# `xpopd` there and return). The stack is a SINGLE slot -- xpushd overwrites
# whatever was there.
function xpushd () {
   dir=${1:-.}
   echo "pushing: ~/.x_push_pop_stack"
   echo "$PWD" > ~/.x_push_pop_stack
}
function xpopd () {
   echo "popping: ~/.x_push_pop_stack"
   if [[ -f ~/.x_push_pop_stack ]]; then
      cd $(command cat ~/.x_push_pop_stack)
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
# get_clip() removed: it was a pre-xclip workaround that drove headless gvim
# to dump the * register to a tempfile. xclip is now installed, kitty does
# OSC 52, and `clipboard=unnamed,unnamedplus` makes nvim yanks land directly
# in the system clipboard. If you ever need raw clipboard text in a script,
# use:   xclip -selection clipboard -o
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
build_from_recipe() {
   local name="$1"
   local version_var="${name^^}_VERSION"
   local version="${!version_var}"

   echo "→ URL: ${build_recipes[$name.url]}"

   # Download
   eval "curl -LO ${build_recipes[$name.url]}"
   eval "tar xf $(basename ${build_recipes[$name.url]})"

   cd "$version" || { echo "❌ Failed to enter $version"; exit 1; }

   # Configure
   echo "→ Configuring: ./configure ${build_recipes[$name.config_cmd]} > configure.log"
   eval "${build_recipes[$name.config_cmd]}" > configure.log

   # Build 
   echo "→ Compiling: make -j$(nproc) > build.log"
   make -j$(nproc) > build.log

   # install
   echo "→ Installing: ${build_recipes[$name.install_cmd]} > install.log"
   eval "${build_recipes[$name.install_cmd]}" > install.log

   cd ..
}
build_all_tools() {
   declare -A seen
   for key in "${!build_recipes[@]}"; do
      name="${key%%.*}"
      seen["$name"]=1
   done

   for name in "${!seen[@]}"; do
      version_var="${name^^}_VERSION"
      version="${!version_var}"
      echo ""
      echo "🔧 Building $name ($version)..."
      start_time=$(date +%s)
      build_from_recipe "$name"
      end_time=$(date +%s)
      elapsed=$((end_time - start_time))
      echo "✅ Finished building $name in $elapsed seconds"
   done
}
