#!/usr/bin/env bash

# format placeholders for git: https://git-scm.com/docs/pretty-formats
# Display reflogs for current or specified local repository
# Usage: gref <repo folder name>;
gref() {

  path='.'
  if [ -n "$1" ]; then
    if [ -d "$1" -a -d "$1/.git" ]; then
        path="$1"
    else
       echo Cannot find git repo at "$1"
    fi
  fi
  git -C "$path" log --walk-reflogs --format="%gd %C(yellow)%h %Cgreen%cd%Cred%d %C(cyan)%gs %Creset%s" --date=format:"%d %b %H:%M"

}
export gref

# Checks style of branch with respect to master rules, and shows an overall number of errors and warnings
# Takes an optional single parameter, either branch name or a hash.
# Usage: checkstyle <branch>
checkstyle() {

    if [ -f ./node_modules/eslint/bin/eslint.js ]; then
        if [ -z "$1" ]; then
            branch="master"
        else
            branch="$1"
        fi
        git checkout master -- .eslintrc
        git reset -q HEAD .eslintrc
        git --no-pager diff --name-only HEAD $(git merge-base HEAD "$branch") | grep ".js$" | xargs node_modules/eslint/bin/eslint.js {} | tail -n 3
        rm .eslintrc
        git checkout .eslintrc
    else
        echo "eslint binary not found"
    fi

}
export checkstyle

# Shows the files changed since the common ancestor
# Usage: changed <branch>
changed() {

    if [ -d ".git" ]; then
        if [ -z "$1" ]; then
            branch="master"
        else
            branch="$1"
        fi
        git diff --name-only HEAD $(git merge-base HEAD "$branch")
    else
        echo "Not a git repository"
    fi

}
export changed

# Checks to see if a merge will produce conflicts
# Usage: checkmerge <branch>
checkmerge() {

    if [ -d ".git" ]; then
        if [ -z "$1" ]; then
            branch="master"
        else
            branch="$1"
        fi
        git merge --no-commit --no-ff $branch
        git merge --abort
    else
        echo "Not a git repository"
    fi

}
export checkmerge

# Simple git one-line log
# Usage git log <commits back> <branch> | gitlog -n 3 master
gitlogx(){
    if [ -d ".git" ]; then
        entries=$1
        branch="$2"
        format="%h %cd | %an | %s"
        date="%m-%d-%y %H:%M"
        if [ -n "$entries" ]; then
            entries="-${entries#-}"
        fi

        git log "$branch" --format="$format" --date=format:"%m-%d-%y %H:%M" $entries | column -ts '|' -T 3
    else
        echo "Not a git repository"
    fi
}
export gitlogx
