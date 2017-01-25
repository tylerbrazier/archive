if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

inoremap <buffer> <silent> < <><left>
inoremap <buffer> <silent> > <c-r>=<SID>CloseTag()<cr>
imap <buffer> <expr> <cr> <SID>Return()

" Gets the current HTML tag by the cursor.
fun s:GetCurrentTag()
	return matchstr(matchstr(getline('.'), '.*<\zs.\+>\%'.col('.').'c'), '^\w*')
endf

" Cleanly return (expand) after autocompleting an html/xml tag.
fun s:Return()
	let tag = s:GetCurrentTag()
	return tag != '' && match(getline('.'), '</'.tag.'>') > -1 ?
				\ "\<cr>\<esc>O" : "\<cr>"
endf

fun s:InComment()
	return stridx(synIDattr(synID(line('.'), col('.')-1, 0), 'name'), 'omment') != -1
endf

" Automatically inserts closing tag after starting tag is typed
fun s:CloseTag()
	let line = getline('.')
	let col = col('.')
	if line[col-1] != '>' | return '>' | endif
	let col += 1
	call cursor(0, col)
	" Don't autocomplete next to a word or another tag or if inside comment
	if line[col] !~ '\w\|<\|>' && !s:InComment()
		let tag = s:GetCurrentTag()
		" Insert closing tag if tag is not self-closing
		" http://www.w3.org/TR/html5/syntax.html#void-elements
		if tag != '' && tag !~ '\varea|base|br|col|embed|hr|img|input|keygen|link|meta|param|source|track|wbr'
			let line = substitute(line, '\%'.col.'c', '</'.escape(tag, '/').'>', '')
			call setline('.', line)
			call cursor(0, col)
		endif
	endif
	return ''
endf
