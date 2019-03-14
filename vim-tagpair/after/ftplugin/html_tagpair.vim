" Lightweight auto-completion plugin for html tags
" Maintainer: Tyler Brazier <tyler@tylerbrazier.com>

" Not guarding on b:did_ftplugin here since this plugin is loaded after the
" default html ftplugin, which sets b:did_ftplugin. :help ftplugin

" elements without closing tags
" http://www.w3.org/TR/html5/syntax.html#void-elements
let s:void_elements = [
      \ 'area',
      \ 'base',
      \ 'br',
      \ 'col',
      \ 'embed',
      \ 'hr',
      \ 'img',
      \ 'input',
      \ 'keygen',
      \ 'link',
      \ 'meta',
      \ 'param',
      \ 'source',
      \ 'track',
      \ 'wbr' ]

inoremap <buffer> <expr> > <sid>complete()
inoremap <buffer> <expr> <cr> <sid>cr()

function! s:complete()
  " :help pattern-overview
  let tag = matchstr(getline('.'), '.*<\zs\w\+\ze')
  if tag == '' || index(s:void_elements, tag) >= 0
    return '>'
  else
    return "></".tag.">\<c-o>:call cursor(0,".(col('.')+1).")\<cr>"
  endif
endfunction

function! s:cr()
  let line = getline('.')
  let col = col('.')
  let charLeft = line[col-2]
  let charRight = line[col-1]
  if charLeft == '>' && charRight == '<'
    return "\<cr>\<esc>O"
  else
    return "\<cr>"
  endif
endfunction
