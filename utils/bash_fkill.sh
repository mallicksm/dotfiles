# shellcheck shell=bash

_fkill_cols() {
   local c

   if [ -n "${COLUMNS:-}" ] && [ "${COLUMNS:-0}" -gt 0 ] 2>/dev/null; then
      printf '%s' "$COLUMNS"
      return
   fi

   if [ -t 1 ] && c=$(tput cols 2>/dev/null) && [ -n "$c" ] && [ "$c" -gt 0 ]; then
      printf '%s' "$c"
      return
   fi

   if c=$({ tput cols < /dev/tty; } 2>/dev/null) && [ -n "$c" ] && [ "$c" -gt 0 ]; then
      printf '%s' "$c"
      return
   fi

   if c=$({ stty size < /dev/tty; } 2>/dev/null | awk '{print $2}') && [ -n "$c" ] && [ "$c" -gt 0 ]; then
      printf '%s' "$c"
      return
   fi

   printf '120'
}

_fkill_fmt_line() {
   local cols
   cols=$(_fkill_cols)
   awk -v cols="$cols" -v pid_w=8 -v cpu_w=2 -v user_w=12 -v comm_w=16 -v col_margin=4 '
      function cmp(a, b,   key_a, key_b) {
         if (pcpu[a] != pcpu[b]) return (pcpu[a] < pcpu[b]) ? 1 : -1
         key_a = user[a] SUBSEP comm[a] SUBSEP args[a]
         key_b = user[b] SUBSEP comm[b] SUBSEP args[b]
         if (key_a == key_b) return 0
         return (key_a > key_b) ? 1 : -1
      }
      BEGIN {
         max = cols - pid_w - user_w - cpu_w - comm_w - 4 - col_margin
         if (max < 20) max = 20
         n = 0
      }
      {
         n++
         pid[n] = $1
         user[n] = $2
         pcpu[n] = $3 + 0
         comm[n] = $4
         $1 = $2 = $3 = $4 = ""
         sub(/^ +/, "")
         args[n] = $0
      }
      END {
         for (i = 1; i <= n; i++) order[i] = i
         for (i = 1; i < n; i++) {
            for (j = i + 1; j <= n; j++) {
               if (cmp(order[i], order[j]) > 0) {
                  tmp = order[i]
                  order[i] = order[j]
                  order[j] = tmp
               }
            }
         }
         for (i = 1; i <= n; i++) {
            k = order[i]
            out_args = args[k]
            if (length(out_args) > max) out_args = substr(out_args, 1, max - 3) "..."
            printf "%*s %-*s %*s %-*s %s\n", pid_w, pid[k], user_w, user[k], cpu_w, pcpu[k], comm_w, comm[k], out_args
         }
      }'
}

_fkill_ps_list() {
   local ps_scope
   if [ "$UID" = "0" ]; then
      ps_scope='-e'
   else
      ps_scope="-u $UID"
   fi
   # shellcheck disable=SC2086
   ps $ps_scope -o pid=,user=,pcpu=,comm=,args= --no-headers 2>/dev/null | _fkill_fmt_line
}

zz_kill() {
   local pid col_header

   export COLUMNS="$(_fkill_cols)"

   col_header=$(printf '%*s %-*s %4s %-*s %s\n' 8 PID 12 USER %CPU 16 COMMAND ARG)

   fzf_header='Select processes to kill
TAB to select multi
ENTER to kill
CTRL-R to refresh

'"$col_header"

   export -f _fkill_cols _fkill_fmt_line _fkill_ps_list

   pid=$(_fkill_ps_list | fzf -m --header="$fzf_header" \
      --bind='ctrl-r:reload(_fkill_ps_list)' | awk '{print $1}')

   if [ "x$pid" != "x" ]; then
      info "Killing selected processes:"
      echo "$col_header"
      for id in $pid; do
         line=$(ps -p "$id" -o pid=,user=,pcpu=,comm=,args= --no-headers 2>/dev/null | _fkill_fmt_line)
         if [ -n "$line" ]; then
            echo "$line"
         else
            warn "pid $id: no longer running (skipped)"
         fi
      done
      echo "$pid" | xargs kill -"${1:-9}"
   else
      echo "No process selected."
   fi
}
# zz_* : user-facing command namespace (type `zz_<TAB>` to discover them).
# fkill kept as a back-compat alias for muscle memory.
alias fkill='zz_kill'
