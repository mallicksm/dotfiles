#!/usr/bin/env bash
#===============================================================================
# Bash Script: bash_lsf.sh
# Created: May-09-2026
# Author: soummya
#
# Description: Thin wrappers around IBM Spectrum LSF (bjobs / bhist / bacct)
# with sensible default columns and a single `lsf <subcommand>` dispatcher.
# Auto-sourced via ~/dotfiles/bash_functions.sh.
#===============================================================================

# Default column formats. Set only if the user has not already overridden them
# in corp_settings.sh / bashrc, so this stays additive.
: "${LSB_BJOBS_FORMAT:=jobid:8 stat:6 queue:8 exec_host:14 job_name:24 submit_time start_time run_time time_left cpu_used max_mem:8 nthreads:3 command:30}"
: "${LSB_BHIST_FORMAT:=jobid:8 user:8 stat:6 queue:8 submit_time start_time finish_time cpu_used max_mem job_name:24}"
: "${LSB_BACCT_FORMAT:=jobid:8 stat:6 queue:8 exec_host:14 job_name:24 submit_time finish_time cpu_used max_mem exit_code}"
export LSB_BJOBS_FORMAT LSB_BHIST_FORMAT LSB_BACCT_FORMAT

# Use existing global helpstr dict if present (set by bash_zellij.sh); otherwise
# create one. -g + no `=()` means "ensure exists, do not reset".
declare -gA helpstr 2>/dev/null
helpstr["lsf"]="\
   usage: lsf <subcommand> [args]
   thin LSF helper around bjobs / bhist / bacct.

      Active jobs (bjobs):
      j | jobs                  list active + recently-finished jobs (default)
      r | running               running only
      p | pending [id]          pending jobs / why one is pending
      l | long      <id>        full long-form info for a job
      use           [filter]    runtime + memory view
      why           <id>        alias of 'pending <id>'
      kill          <id|name>   bkill <id|name>            (use 0 = all)
      <jobid>                   shortcut for 'lsf long <jobid>'

      History (bhist — event log):
      h | hist  [id]            event log (one job if id given)
      hd                        done jobs only (bhist -d -aw)

      Accounting (bacct — finished jobs):
      a | acct                  one-row-per-job accounting for \$USER
      fails                     only EXIT'd jobs
      last  <DATE-EXPR>         e.g.  lsf last 'last week'  |  lsf last '7 days ago'
      since <yyyy/mm/dd>        accounting since explicit date

      Misc:
      fmt                       show current LSB_*_FORMAT env vars
      raw <bjobs|bhist|bacct> [args]   pass straight through with our defaults
      help | -h | --help        this help

   Tip: column widths in LSB_BJOBS_FORMAT use field:N notation. To override
        the default, export your own LSB_BJOBS_FORMAT before this file loads.
"

function lsf() {
   local sub="${1:-jobs}"
   [[ $# -gt 0 ]] && shift
   if [[ "$sub" =~ ^[0-9]+$ ]]; then
      command bjobs -l "$sub" "$@"
      return $?
   fi
   case "$sub" in
      -h|--help|help)
         printf '%b\n' "${helpstr[lsf]}"
         ;;
      j|jobs)
         command bjobs -aw -hms "$@"
         ;;
      r|running)
         command bjobs -rw -hms "$@"
         ;;
      p|pending|why)
         if [[ -n "$1" ]]; then
            command bjobs -p "$@"
         else
            command bjobs -pw "$@"
         fi
         ;;
      l|long)
         if [[ -z "$1" ]]; then
            echo "usage: lsf long <jobid>"
            return 1
         fi
         command bjobs -l "$@"
         ;;
      use)
         command bjobs -aw -hms -o "jobid:8 stat:6 run_time cpu_used max_mem:10 nthreads:3 exec_host:14 job_name:30" "$@"
         ;;
      kill)
         if [[ -z "$1" ]]; then
            echo "usage: lsf kill <jobid|name|0>     (0 = all your jobs)"
            return 1
         fi
         command bkill "$@"
         ;;
      h|hist)
         if [[ -n "$1" ]]; then
            command bhist -l "$@"
         else
            command bhist -aw
         fi
         ;;
      hd)
         command bhist -d -aw "$@"
         ;;
      a|acct)
         command bacct -W -hms -u "$USER" "$@"
         ;;
      fails)
         command bacct -x -W -hms -u "$USER" "$@"
         ;;
      last)
         if [[ -z "$1" ]]; then
            echo "usage: lsf last <DATE-EXPR>     e.g.  lsf last '7 days ago'  |  lsf last 'last monday'"
            return 1
         fi
         local since
         since=$(date -d "$1" +%Y/%m/%d 2>/dev/null)
         if [[ -z "$since" ]]; then
            echo "Could not parse date: $1"
            return 1
         fi
         shift
         command bacct -W -hms -u "$USER" -S "$since" "$@"
         ;;
      since)
         if [[ -z "$1" ]]; then
            echo "usage: lsf since <yyyy/mm/dd>"
            return 1
         fi
         local s="$1"; shift
         command bacct -W -hms -u "$USER" -S "$s" "$@"
         ;;
      fmt)
         echo "LSB_BJOBS_FORMAT=$LSB_BJOBS_FORMAT"
         echo "LSB_BHIST_FORMAT=$LSB_BHIST_FORMAT"
         echo "LSB_BACCT_FORMAT=$LSB_BACCT_FORMAT"
         ;;
      raw)
         if [[ -z "$1" ]]; then
            echo "usage: lsf raw <bjobs|bhist|bacct> [args]"
            return 1
         fi
         local cmd="$1"; shift
         case "$cmd" in
            bjobs|bhist|bacct|bkill|bsub|bqueues|bhosts) command "$cmd" "$@" ;;
            *) echo "Refusing to exec: $cmd"; return 1 ;;
         esac
         ;;
      *)
         echo "Unknown subcommand: $sub"
         printf '%b\n' "${helpstr[lsf]}"
         return 1
         ;;
   esac
}
