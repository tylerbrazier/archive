if exists('g:loaded_outlaw') || &cp
  finish
endif
let g:loaded_outlaw = 1

command! -nargs=* -bang Odiff call <sid>Odiff(<bang>0, <f-args>)
command! -nargs=* -bang -range=0 Ogrep call <sid>Ogrep('<bang>', <count>, <f-args>)
command! -nargs=* -bang -range=0 Olog call <sid>Olog(<bang>0, <count>, <line1>, <line2>, <f-args>)

function! s:err(message)
  echohl ErrorMsg
  echo a:message
  echohl None
endfunction

" this function serves two purposes:
" - it gets the root of the current git dir
" - it throws an error if we're not in a git dir or if there's no git
"   executable. Since the commands in this script will all need to know the
"   git root, each should call this function first and return early if they
"   catch an error.
function! s:gitdir()
  let result = system('git rev-parse --show-toplevel')[:-2] "trim trailing \n
  if isdirectory(result)
    return result
  else
    call s:err(result)
    throw result
  endif
endfunction


" populates the quickfix list with the first line of each hunk in git diff
function! s:Odiff(bang, ...) abort
  try
    let gitdir = s:gitdir()
  catch
    return
  endtry
  " git diff output looks like:
  "
  " diff --git a/file b/file
  " index 123abc..456def 100666
  " --- a/file
  " +++ b/file
  " @@ -1 +1,2 @@
  " -first line (deleted)
  " +first was replaced with this
  " +this line was added
  " @@ -3,0 +5 @@
  " +another new line

  let cmd = 'git --no-pager diff -U0 --no-color --no-ext-diff '.join(a:000,' ')
  let lines = systemlist(cmd)

  if v:shell_error > 0
    return s:err(join(lines, "\n"))
  endif

  let result = []
  let filename = v:null
  let i = 0
  while i < len(lines)
    let line = lines[i]
    " need to check for 'index' line instead of '---' or '+++' in case
    " text in the diff begins in '++' or '--' since the diff will add another
    " '-' or '+' for changed lines
    if line =~ '^index'
      let filename = s:parseFileName(lines[i+2], gitdir)
      let i = i + 3 "move to the line after the '+++'
    elseif filename != v:null && line =~ '^@@'
      " line number is after the '+' on the @@ line (:help pattern-overview)
      let lnum = matchstr(line,'+\zs\d\+\ze')
      let text = substitute(lines[i+1], '^[-+]\zs\s*\ze', '', '')
      call add(result, {'filename':filename, 'lnum':lnum, 'text':text})
      let i = i + 2 "move past the first diff line in this hunk
    else
      let i = i + 1
    endif
  endwhile

  if empty(result)
    echo 'No changes'
    return
  endif

  call setqflist(result, 'r') "replace

  if !a:bang
    cfirst
  endif
endfunction


" returns v:null if the file is /dev/null (it's been deleted)
function! s:parseFileName(line, gitdir) abort
  let filename = a:line[4:] "remove leading '+++ ' or '--- '
  if filename == '/dev/null'
    return v:null
  else
    return a:gitdir.filename[1:] "[1:] removes leading 'a' or 'b'
  endif
endfunction


" git :grep
function! s:Ogrep(bang, visual, ...)
  try
    let gitdir = s:gitdir()
  catch
    return
  endtry

  let args = copy(a:000)
  if a:visual
    " append visual selection to args
    let origx = getreg('x')
    normal! gv"xy
    call add(args, getreg('x'))
    call setreg('x', origx)
  endif

  if empty(args)
    return s:err('Arguments required')
  endif

  let origgp = &grepprg
  let origgfm = &grepformat
  let origcwd = getcwd()

  set grepprg=git\ --no-pager\ grep\ --no-color\ --full-name\ -I\ -n
  set grepformat=%f:%l:%m
  execute 'cd' gitdir

  execute 'grep'.a:bang join(args, ' ')

  let &grepprg = origgp
  let &grepformat = origgfm
  execute 'cd' origcwd
endfunction


function! s:Olog(bang, visual, line1, line2, ...) abort
  try
    call s:gitdir() "make sure we're in a git dir
  catch
    return
  endtry

  let path = expand('%:p')
  if empty(path)
    call s:err('Not editing a file')
    return
  endif

  let logargs = join(a:000, ' ').' -p '
  if a:visual
    let logargs .= '-L '.a:line1.','.a:line2.':'.path
  else
    let logargs .= '--follow -- '.path
  endif

  let tmpfile = tempname()
  let stderr = system('git --no-pager log '.logargs.' > '.tmpfile)

  if v:shell_error > 0
    return s:err(stderr[:-2]) "trim trailing \n
  endif

  try
    " the commit message is the second line after Date:...
    execute 'vimgrep /^Date.*\n\n\zs.*\ze/'.(a:bang ? 'j' : '') tmpfile
  catch
    redraw | echo 'No log'
  endtry
endfunction
