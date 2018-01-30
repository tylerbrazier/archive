if exists('g:loaded_chronolog')
  finish
endif
let g:loaded_chronolog = 1

command! -nargs=* -complete=file ChronoLog
      \ call <sid>doit('log', 0, <q-mods>, <f-args>)

command! -nargs=* -complete=file ChronoShow
      \ call <sid>doit('show', 0, <q-mods>, <f-args>)

command! -nargs=* -complete=file ChronoBlame
      \ call <sid>doit('blame', 1, <q-mods>, <f-args>)

function! s:doit(subcmd, jump, mods, ...) abort
  " prepend the temp name with subcmd_; e.g. /tmp/blame_4
  let tmp = substitute(
        \ tempname(),
        \ '\(.*[/\\]\)\?\([^/\\]\+\)',
        \ {m -> m[1].a:subcmd.'_'.m[2]},
        \ '')

  let gitcmd = 'git --no-pager '.a:subcmd.' '.join(a:000, ' ')
  let stderr = system(gitcmd.' > '.tmp)

  if v:shell_error > 0
    echohl ErrorMsg | echo stderr[:-2] | echohl None "[:-2] strips trailing \n
    return
  endif

  " if jump is set and the last argument is the current file,
  " open the tmp file on the same line as we're on in the current file
  let jump = a:jump && a:000[-1] == expand('%')

  execute a:mods 'new' (jump ? '+'.line('.') : '') tmp
  redraw | echo gitcmd
endfunction
