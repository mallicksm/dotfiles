prompt_git() {
   local s='';
   local branchName='';
   local gitStatus='';
   local dollar='$';
   local dateTime=$(date +"%a %b %d %Y, %I:%M %p");

   local c_hostname=#[fg='red'];
   local c_branch=#[fg='colour199'];
   local c_datetime=#[fg='blue'];

   local c_style=#[fg='yellow'];
   local c_deleted=#[fg='red'];
   local c_modified=#[fg='yellow'];
   local c_untracked=#[fg='yellow'];
   local c_staged=#[fg='green'];
   local c_up_to_date=#[fg='yellow'];
   local c_ahead=#[fg='green'];
   local c_diverged=#[fg='yellow'];
   local c_behind=#[fg='yellow'];

   local c_default=#[fg=default];

   # Check if the current directory is in a Git repository.
   if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then

      # check if the current directory is in .git before running git checks
      if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

         if [[ -O "$(git rev-parse --show-toplevel)/.git/index" ]]; then
            git update-index --really-refresh -q &> /dev/null;
         fi;

         # run git status once and extract the number of files' status
         gitStatus=$(git status --ignore-submodules -sb)
         untracked=$(echo "$gitStatus"|grep '??'|wc -l)
         deleted=$(echo "$gitStatus"|grep 'D'|wc -l)
         modified=$(echo "$gitStatus"|grep '.M '|wc -l)
         added=$(echo "$gitStatus"|grep '.A'|wc -l)
         added_staged=$(echo "$gitStatus"|grep '^A'|wc -l)
         modified_staged=$(echo "$gitStatus"|grep '^M'|wc -l)
         staged=$(($added_staged + $modified_staged))

         # color & place symbols, count for the files' status
         [[ $deleted > 0 ]]   && s+="${c_deleted}✘${deleted}${c_default}";
         [[ $modified > 0 ]]  && s+="${c_modified}${modified}${c_default}";
         [[ $staged > 0 ]]    && s+="${c_staged}+${staged}${c_default}";
         [[ $untracked > 0 ]] && s+="${c_untracked}${untracked}${c_default}";

         # Check for stashed files.
         if git rev-parse --verify refs/stash &>/dev/null; then
            s+="${c_style}${dollar}${c_default}";
         fi;

         # run git status again to check for ahead behind or up_to_date
         ahead_behind=$(git status -sb)
         behind=$(echo "$ahead_behind" |grep behind| sed -E 's/.*\[behind (.)+\]/\1/')
         ahead=$(echo "$ahead_behind"  |grep ahead | sed -E 's/.*\[ahead (.)+\]/\1/')
         if [[ $ahead > 0 ]]; then
            s+="$c_ahead⇡${ahead}$c_default";
         elif [[ $behind > 0 ]]; then
            s+="$c_behind⇣${behind}$c_default";
         else
            s+="${c_up_to_date}✓${c_default}";
         fi
      fi;

      # Get the short symbolic ref.
      # If HEAD isn?t a symbolic ref, get the short SHA for the latest commit
      # Otherwise, just give up.
      branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
         git rev-parse --short HEAD 2> /dev/null || \
         echo '(unknown)')";

      [ -n "${s}" ] && s=" ${c_style}[${c_default}${s}${c_style}]${c_default}";

      gitStatus="$c_branch[ ${branchName}]$c_default${s}";
   else
      gitStatus=""
   fi;
   dateTimeStatus="${c_dateTime}$dateTime${c_default}"
   hostnameStatus="${c_hostname}$(hostname -s):${c_default}"
   echo -e "$dateTimeStatus $hostnameStatus $gitStatus"
}

prompt_git
