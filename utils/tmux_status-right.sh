prompt_git() {
   local s='';
   local branchName='';

   # Check if the current directory is in a Git repository.
   if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then

      # check if the current directory is in .git before running git checks
      if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

         if [[ -O "$(git rev-parse --show-toplevel)/.git/index" ]]; then
            git update-index --really-refresh -q &> /dev/null;
         fi;

         git status --ignore-submodules -sb > /tmp/_git
         untracked=$(cat /tmp/_git|grep '??'|wc -l)
         deleted=$(cat /tmp/_git|grep 'D'|wc -l)
         modified=$(cat /tmp/_git|grep '.M '|wc -l)
         added=$(cat /tmp/_git|grep '.A'|wc -l)
         added_staged=$(cat /tmp/_git|grep '^A'|wc -l)
         modified_staged=$(cat /tmp/_git|grep '^M'|wc -l)
         staged=$(($added_staged + $modified_staged))

         # Check for deleted changes in the index.
         if [[ $deleted > 0 ]]; then
            s+="✘${deleted}";
         fi

         # Check for modified changes in the index.
         if [[ $modified > 0 ]]; then
            s+="${modified}";
         fi

         # Check for staged changes in the index.
         if [[ $staged > 0 ]]; then
            s+="+${staged}";
         fi

         # Check for untracked changes in the index.
         if [[ $untracked > 0 ]]; then
            s+="${untracked}";
         fi

         # Check for stashed files.
         if git rev-parse --verify refs/stash &>/dev/null; then
            s+='$';
         fi;

      fi;

      # Get the short symbolic ref.
      # If HEAD isn?t a symbolic ref, get the short SHA for the latest commit
      # Otherwise, just give up.
      branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
         git rev-parse --short HEAD 2> /dev/null || \
         echo '(unknown)')";

      [ -n "${s}" ] && s=" [${s}]";

      echo -e "$(hostname -s): [ ${branchName}]${s}";
   else
      echo -e "$(hostname -s):";
   fi;
}

prompt_git
