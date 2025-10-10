#!/bin/bash
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
export GIT_TERMINAL_PROMPT=0

timestamp() {
  date +'%Y-%m-%d %H:%M:%S'
}

cd /Users/bryan/Code/GitHub/liby || exit 1

LOCKDIR="/tmp/git-sync-liby.lock"
mkdir "$LOCKDIR" 2>/dev/null || exit 0
trap 'rmdir "$LOCKDIR"' EXIT

git config commit.gpgsign false

if [ -n "$(git status --porcelain)" ]; then
  git add --all
  git commit -m "docs: 📝 update on $(timestamp)"
fi

git pull --rebase --autostash origin master || {
  echo "[ERROR] Git pull failed at $(timestamp)" >&2
  exit 1
}

git push origin master || {
  echo "[ERROR] Git push failed at $(timestamp)" >&2
  exit 1
}
