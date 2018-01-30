# vim-chronolog

Small vim plugin with commands for viewing git history.

- `:ChronoLog [args]`
- `:ChronoShow [args]`
- `:ChronoBlame [args]`

Each opens a new window with the output of `git log/show/blame` with the given
`args` passed to the underlying git command (any `%` in args will be expanded
to represent the current file name). The commands can be preceded with
modifiers such as `:tab` and `:vert` to control how the window opens.

For example, `:tab ChronoBlame %` opens `git blame` for the current file in a
new tab.
