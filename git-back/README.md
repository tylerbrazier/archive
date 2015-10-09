git back
========
*When I implemented this, I didn't realize that you could simply have an
executable in your $PATH named 'git-back' and it would allow you to run the
command `git back`; that's why it ended up just being one long alias.
I'm archiving this project because it would be better to implement it in a real
programming language without having to escape every line.*

Defines a `git back` alias that can be used to backup and synchronize
directories using git.

**Why use git for file sync instead of something like Dropbox or rsync?**

- Dropbox is limited; you can only store up to 2G for free and any files
  that you want to sync need to be placed in the ~/Dropbox folder.
  With this tool, any directory that can become a git repo can be synced
  and the size is only limited by the file system.
- No lost updates; with rsync, files are updated based on their modification
  times. This means if two hosts have unsynced clocks or are in different
  timezones, some updates can easily be overwritten. Git introduces changes
  by commits rather than times so this is never an issue.
- No in-place updates; changes come in on a separate branch that is not
  checked out so that your working files are not unexpectedly updated.
  You can merge the changes when you're ready.
- It's distributed; there is no central server that each client pushes to
  and pulls from. Instead, every node can act as both client and server -
  changes are pushed to all and pulled from all so there doesn't have to be
  a single point of failure.
- Git is awesome at keeping history and merging changed files.
  Conflict resolution is also made easy with `git mergetool` and such.

The general idea is that each directory you want to synchronize is just a git
repository with a special `_backed` branch. We'll call this a *backed* repo.
Run `git back here` to create or clone the backed repo. You should not check
out the `_backed` branch - when other backed clones need to push (using
`git back up`) or pull changes (using `git back down`) for synchronization,
they are pushed to and pulled from the `_backed` branch so that any uncommitted
files in the working directory are unaffected by the sync.

Setup
-----
The only dependency is git.
Windows users can install [git for windows][git-for-win].
I haven't tested this with cygwin but there shouldn't be a problem.

To use the `git back` alias, source the file in your `~/.gitconfig` like:

    [include]
      path = /path/to/git-back

Run `tests.sh` to make sure everything is working right.

Usage
-----
`git back` has three (optional) subcommands.

    git back [here|up|down]

--------------------------------------------

    git back here [<repo to clone>]

Initializes a backed repo or clones an existing one.

Without the argument, this command will `git init` in the current directory,
make an initial commit, and create the `_backed` branch. To clone an existing
backed repo, give its url as an argument and it will be cloned into the current
dir as `backed/origin`.

--------------------------------------------

    git back up

Commits and pushes changes to all `backed/` remotes.

Specifically, this command adds any uncommitted changes in the current directory
to the index, makes a commit, and merges `HEAD` into `_backed`.
Then `_backed` is pushed to each remote who's name begins with `backed/`.

--------------------------------------------

    git back down

Brings the current dir up to date by pulling from each `backed/` remote.

Specifically, it stashes any uncommitted changes in the current directory,
checks out `_backed`, fetches from each remote who's name begins with `backed/`,
merges each remote branch `backed/*/_backed`, checks out `master` (or whatever
`HEAD` was previously), merges `_backed` into `HEAD`, then pops the stash.

--------------------------------------------

    git back

Without a subcommand, `git back` syncs the current dir with each `backed/`
remote.

Specifically, `git back down && git back up`.

Adding remotes
--------------
To connect multiple backed repos, you just need to give them each a remote name
that is within the `backed/` namespace; e.g.:

    git remote add backed/server1 git@server1.example.com:/sync-me

When `git back` makes a commit, the message contains the hostname of the
current machine. This is so that you can look up where a change originated
using `git log`. When adding remotes, consider including the hostname of the
remote machine in its remote name.

Notes/caveats
-------------
- Although possible, there's no real reason why you'd use this in an
  existing git repo; it would just dirty the log with silly commits.
- Be careful not to have subdirectories that are git repos within a backed
  repo - this will likely cause unexpected behavior.
- TODO: find a good way to handle conflicts. Right now if a conflict
  happens, you're on your own to resolve it, make the commit, and get off
  the `_backed` branch.

[git-for-win]: http://git-scm.com/download/win
