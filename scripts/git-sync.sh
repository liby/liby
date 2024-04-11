#!/bin/sh

DATE=$(date +"%Y-%m-%d %H:%M:%S")
MESSAGE="Nothing to commit"
git config commit.gpgsign false

if [ -n "$(git status -s)" ]; then
  echo "Checked for changes:" ${DATE}
  git add --all
  git commit -m "docs: 📝 update on ${DATE}"
  git remote -v | grep fetch | awk '{print $2}' | git pull --rebase origin master
  git push
elif [ -n "$(git status)" ]; then
  git remote -v | grep fetch | awk '{print $2}' | git pull --rebase origin master
  git push
else
  echo ${MESSAGE}
fi
