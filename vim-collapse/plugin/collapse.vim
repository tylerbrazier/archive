" Better indent folding.
" Toggling fold on a line will fold everything below it with greater indent.
" It stops folding before it reaches a line with indent equal to or less
" than the current line or before whitespace (empty) line(s) preceding a
" line with equal or less indent.
" The meat of this was taken verbatim from this awesome site:
" http://learnvimscriptthehardway.stevelosh.com/chapters/49.html

if exists('g:loaded_collapse')
    finish
endif
let g:loaded_collapse = 1


function! collapse#foldexpr(lnum)
    if getline(a:lnum) =~? '\v^\s*$'
        return '-1'
    endif

    let this_indent = s:IndentLevel(a:lnum)
    let next_indent = s:IndentLevel(s:NextNonBlankLine(a:lnum))

    if next_indent == this_indent
        return this_indent
    elseif next_indent < this_indent
        return this_indent
    elseif next_indent > this_indent
        return '>' . next_indent
    endif
endfunction


function! s:IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction


function! s:NextNonBlankLine(lnum)
    let numlines = line('$')
    let current = a:lnum + 1

    while current <= numlines
        if getline(current) =~? '\v\S'
            return current
        endif

        let current += 1
    endwhile

    return -2
endfunction


" No 'x lines:' as part of folded line
function! collapse#foldtext()
    let line = getline(v:foldstart)
    let prefix = '+'.repeat('-', indent(v:foldstart)-2).' '  " +----
    let postfix = ' '

    let line = substitute(line, '\v^\s+', prefix, '')  " sub leading whitespace
    let line = substitute(line, '\v$', postfix, '')    " sub the ending
    return line
endfunction


set foldmethod=expr
set foldexpr=collapse#foldexpr(v:lnum)
set foldtext=collapse#foldtext()
