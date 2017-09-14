# outlaw.vim

Lightweight [fugitive][]-inspired git plugin for vim.

```
:Odiff[!] [args]
```
populates the quickfix list with the first line of each hunk in git diff so you
can use `:cn`,`:cp`, and friends to jump between changes in your project.
Unless `!` is given the first change is jumped to.
Any additional `[args]` will be passed to `git diff`.

```
:Ogrep[!] [args]
```
`git :grep[!]` with `[args]` and/or visual selection.

```
:Olog[!] [opts]
```
does git log for the current file and populates the quickfix list with an entry
for each commit so you can use `:cn`,`:cp`, and friends to jump between them.
Works in visual mode to get a log of only the selected lines.
Unless `!` is given the first commit is jumped to.
`[opts]` are any additional options to pass to `git log` (e.g. `-4` to limit
the number of commits to 4).

## TODO
- should `Odiff` show new and deleted files?
- add `Oshow` command for viewing full commit from `Olog`
- name `Olog` file something other than a random number chosen by `tempname()`

## Why not just contribute to fugitive?
- The commands in this plugin behave differently than fugitive
- Fugitive uses the current file to determine the git dir; outlaw uses the cwd
  so it works in a new tab window
- Fugitive has a lot of functionality that I personally don't use so I just
  wanted to make a smaller alternative (fugitive is 3000+ sloc)


[fugitive]: https://github.com/tpope/vim-fugitive
