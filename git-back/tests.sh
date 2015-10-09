#!/bin/sh

# Unit tests. You'll need to source the git-back file from your ~/.gitconfig
# for this to work.

usage="Usage: $0 <all|here|up|down>"

# Should be the first thing you do to set up a test.
# Pass a single arg that describes what's being tested.
it() {
  wd="/tmp/git-back.tmp"  # should not be in subdir of another git repo
  cd "$wd/.." || exit 1 # make sure we're not in working dir before deleting it
  rm -rf "$wd"
  mkdir "$wd" || exit 1
  cd "$wd"
  echo
  echo '---------------------------------------------------------------------'
  echo "TEST: $1"
  echo '---------------------------------------------------------------------'
}

# Use to check the value returned by the previous command.
# The first arg should be $? and the second is what value you expect $? to be.
verify_status() {
  [ $1 -eq $2 ] || { echo "TEST: Got unexpected return value $1" >&2; exit 1; }
}

verify_head() {
  echo "TEST: Verifying $branch is not checked out"
  [ "$(git symbolic-ref HEAD)" != "$branch" ]
  verify_status $? 0
}

branch='_backed'
remote_ns='backed' # remote name space

git_back_here() {
  printf '\nTEST: git back here\n'
  echo '=================================================='

  # Use to check if $branch exists in the current repo.
  # Takes a single arg:
  #   0 if the branch should exist
  #   1 if it should not
  verify_branch() {
    git show-ref -q --verify "refs/heads/$branch"
    verify_status $? $1
  }

  it "Should create a repo and $branch branch in an empty directory"
  git back here
  verify_status $? 0
  verify_branch 0

  it "On clone, it should check out master branch instead of remote's HEAD"
  git init A >/dev/null; cd A
  touch a; git add a; git commit -m 'add a' >/dev/null
  git checkout -b "$branch"
  mkdir ../B; cd ../B
  git back here ../A
  verify_status $? 0
  verify_branch 0
  echo "TEST: Verifying master is checked out"
  [ "$(git symbolic-ref --short HEAD)" = "master" ]
  verify_status $? 0

  it "Should clone existing repo with latest commits on $branch and on master"
  git init A >/dev/null; cd A
  touch a; git add a; git commit -m 'add a' >/dev/null
  git checkout -b "$branch"
  touch b; git add b; git commit -m 'add b' >/dev/null
  # for some reason `git show-ref --hash HEAD` doesn't work...
  head_hash=$(cat ".git/refs/heads/$branch")
  mkdir ../B; cd ../B
  git back here ../A
  verify_status $? 0
  verify_branch 0
  echo "TEST: Verifying commit"
  [ $(cat .git/refs/heads/master) = "$head_hash" ]; verify_status $? 0

  it "Should add existing files in cwd when creating a new repo"
  touch a b
  git back here
  verify_status $? 0
  echo 'TEST: Verifying there are no dirty files in cwd'
  [ -z "$(git status --porcelain)" ]
  verify_status $? 0
  verify_branch 0

  it "Should be able to clone an emtpy repo as long as it has master branch"
  git init A
  cd A; git commit --allow-empty -m 'empty'
  mkdir ../B; cd ../B
  git back here ../A
  verify_status $? 0
  verify_branch 0

  it "Should fail if already in a git repo"
  git init A >/dev/null; cd A
  git back here
  verify_status $? 1
  verify_branch 1

  it "Should fail if trying to clone when there are files in cwd"
  git init A >/dev/null; mkdir B
  cd B
  touch a b
  git back here ../A
  verify_status $? 1

  it "Should fail if given more than one argument"
  git init A >/dev/null
  git init B >/dev/null
  mkdir C; cd C
  git back here ../A ../B
  verify_status $? 1
}

# Set up repos A, B, C, and D that can be used for tests.
# A is the original, and B, C, and D are clones.
# They each have a remote reference to each other but D has a remote
# name that is not in the namespace.
prepare_repos() {
  mkdir A; cd A; git back here >/dev/null; cd ..
  for i in B C D; do
    mkdir $i; cd $i
    git back here ../A >/dev/null
    # each of $i will self reference but whatever
    git remote add "${remote_ns}/B" ../B
    git remote add "${remote_ns}/C" ../C
    git remote add "${remote_ns}_nope/D" ../D
    cd ..
  done
  cd A
  git remote add "${remote_ns}/B" ../B
  git remote add "${remote_ns}/C" ../C
  git remote add "${remote_ns}_nope/D" ../D
  cd ..
}

git_back_down() {
  printf '\nTEST: git back down\n'
  echo '=================================================='

  it "Should pull from each remote in namespace and merge into current branch"
  prepare_repos
  # add a unique file in each repo
  for i in B C D; do
    cd $i; touch $i; git add $i; git commit -m "add $i" >/dev/null
    # merge changes into $branch
    git fetch . "HEAD:$branch" 2>/dev/null
    cd ..
  done
  cd A
  git back down
  verify_status $? 0
  verify_head
  verify_cwd() {
    h="$(git symbolic-ref --short HEAD)"
    echo "TEST: Verifying files B and C exist in $h"
    [ -f B ] && [ -f C ]; verify_status $? 0
    echo "TEST: Verifying file D does not exist in $h"
    [ -f D ]; verify_status $? 1
  }
  verify_cwd
  git checkout $branch
  verify_cwd

  it "Should merge $branch even if there are no remotes"
  git back here >/dev/null
  git checkout $branch
  touch a; git add a; git commit -m 'add a'
  git checkout master
  git back down
  verify_status $? 0
  echo "TEST: Verifying file 'a' exists"
  [ -f a ]; verify_status $? 0
  verify_head

  it "Should stash uncommitted changes and unstash after"
  prepare_repos
  cd B
  # one added...
  touch a; git add a
  # and one untracked
  touch b
  git back down
  verify_status $? 0
  echo 'TEST: Verifying status of untracked files'
  git status --porcelain | grep 'A  a' >/dev/null; verify_status $? 0
  git status --porcelain | grep '?? b' >/dev/null; verify_status $? 0
  verify_head

  it "Should not fail even if remote doesn't have the $branch branch"
  mkdir A; cd A; git back here
  git branch -D $branch
  mkdir ../B; cd ../B; git back here ../A
  git back down
  verify_status $? 0
  verify_head

  it "Conflict should cause failure. For now it's up to user to fix conflicts"
  prepare_repos
  for i in A B; do
    cd $i
    git checkout $branch 2>/dev/null
    echo "$i" > clash
    git add clash; git commit -m "add clash from $i" >/dev/null
    git checkout master 2>/dev/null
    cd ..
  done
  cd C
  git back down
  verify_status $? 1

  it "Should fail if not in a git repo"
  git back down
  verify_status $? 1

  it "Should fail if $branch is checked out"
  git back here >/dev/null
  git checkout $branch
  git back down
  verify_status $? 1
  verify_head

  it "Should fail in empty repo"
  git init
  git back down
  verify_status $? 1
  verify_head

  it "Should fail if $branch doesn't exist"
  git init >/dev/null
  touch a
  git add a; git commit -m 'add a' >/dev/null
  git back down
  verify_status $? 1
  verify_head
}

git_back_up() {
  printf '\nTEST: git back up\n'
  echo '=================================================='

  it "Should commit and push to remotes in namespace"
  prepare_repos
  cd A
  touch a;
  git back up
  verify_status $? 0
  verify_head
  echo 'TEST: Verifying the change has been committed'
  n=$(git status --porcelain) && [ -z "$n" ]
  verify_status $? 0
  cd ..
  for i in B C; do
    cd $i; git checkout $branch 2>/dev/null
    echo "TEST: Verifying 'a' exists in $i"
    [ -f a ]; verify_status $? 0
    cd ..
  done
  cd D
  echo "TEST: Verifying 'a' does not exist in D"
  [ -f a ]; verify_status $? 1

  it "Should be able to push to emtpy cloned repo"
  git init A >/dev/null
  cd A; git commit --allow-empty -m 'empty' >/dev/null
  mkdir ../B; cd ../B
  git back here ../A >/dev/null
  touch b
  git back up
  verify_status $? 0
  verify_head
  echo "TEST: Verifying 'b' exists on $branch in origin"
  cd ../A; git checkout $branch 2>/dev/null
  [ -f b ]; verify_status $? 0

  it "Should bail if $branch is ahead of master"
  prepare_repos >/dev/null
  cd A
  git checkout $branch
  touch a; git add a; git commit -m 'add a'; >/dev/null
  git checkout master
  git back up
  verify_status $? 1
  verify_head
  cd ../B
  echo "TEST: Verifying B does not have the change"
  git checkout $branch 2>/dev/null
  [ -f a ]; verify_status $? 1
}

if [ "$1" = "all" ]; then
  git_back_here &&
  git_back_down &&
  git_back_up &&
  printf '\nTEST: all passed :)\n'
elif [ "$1" = "here" ]; then
  git_back_here &&
  printf '\nTEST: passed :)\n'
elif [ "$1" = "down" ]; then
  git_back_down &&
  printf '\nTEST: passed :)\n'
elif [ "$1" = "up" ]; then
  git_back_up &&
  printf '\nTEST: passed :)\n'
else
  echo "$usage" >&2
  exit 1
fi
