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
function has() {
   command -v "$1" 1>/dev/null 2>&1
}
function Pushd() {
   pushd "$@" >/dev/null 2>&1
}
function Popd() {
   popd >/dev/null 2>&1
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
   file="$1"
   url="$2"

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
