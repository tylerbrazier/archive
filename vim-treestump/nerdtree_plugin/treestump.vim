if exists('g:loaded_treestump')
  finish
endif
let g:loaded_treestump = 1

call NERDTreeAddKeyMap({
      \ 'key': '<c-c>',
      \ 'callback': 'TreestumpCopy',
      \ 'quickhelpText': 'Copy',
      \ 'scope': 'Node' })

call NERDTreeAddKeyMap({
      \ 'key': '<c-x>',
      \ 'callback': 'TreestumpMove',
      \ 'quickhelpText': 'Cut',
      \ 'scope': 'Node' })

call NERDTreeAddKeyMap({
      \ 'key': '<c-v>',
      \ 'callback': 'TreestumpPaste',
      \ 'quickhelpText': 'Paste',
      \ 'scope': 'Node' })

call NERDTreeAddKeyMap({
      \ 'key': '<del>',
      \ 'callback': 'NERDTreeDeleteNode',
      \ 'quickhelpText': 'Delete' })


function! TreestumpCopy(node)
  let g:treestump_clipboard = a:node
  let g:treestump_pending_op = 'copy'
  echo 'Copied '.a:node.path.str()
endfunction


function! TreestumpMove(node)
  let g:treestump_clipboard = a:node
  let g:treestump_pending_op = 'move'
  echo 'Cut '.a:node.path.str()
endfunction


function! TreestumpPaste(node)
  if !exists('g:treestump_clipboard')
    echo 'Nothing to paste'
    return
  endif

  if g:treestump_pending_op == 'copy'
    call s:doCopy(g:treestump_clipboard, a:node)
  elseif g:treestump_pending_op == 'move'
    call s:doMove(g:treestump_clipboard, a:node)
  else
    echo "Unknown operation '".g:treestump_pending_op."'"
  endif
endfunction


function! s:doCopy(srcNode, destNode)
  " stole most of this from NERDTreeCopyNode in the fs_menu.vim bundled plugin

  " strip trailing slash
  let destPath = substitute(a:destNode.path.str(), '\/$', '', '')

  if a:srcNode.path.copyingWillOverwrite(destPath)
    echo 'Warning: copying may overwrite files! Continue? [y/N] '
    if nr2char(getchar()) !=? 'y'
      return
    endif
  endif

  try
    let newNode = a:srcNode.copy(destPath)
    if empty(newNode)
      call b:NERDTree.root.refresh()
      call b:NERDTree.render()
    else
      call NERDTreeRender()
      call newNode.putCursorHere(0, 0)
    endif
  catch /^NERDTree/
    echo 'Error copying node'
  endtry

  redraw
endfunction


function! s:doMove(srcNode, destNode)
  let bufnum = bufnr("^".a:srcNode.path.str()."$")
  if bufnum != -1 && getbufvar(bufnum, '&mod')
    echo 'The source file is modified in buffer '.bufnum.'. Aborting.'
    return
  endif

  if a:destNode.path.isDirectory
    let newPath = a:destNode.path.str()
          \ . g:NERDTreePath.Slash()
          \ . a:srcNode.path.getLastPathComponent(a:srcNode.path.isDirectory)
  else
    let newPath = a:destNode.path.str()
  endif

  " similar logic to NERDTreeMoveNode in the fs_menu.vim bundled plugin
  try
    call a:srcNode.rename(newPath)
    unlet g:treestump_clipboard
    call NERDTreeRender()
    call a:destNode.putCursorHere(1, 0)
    redraw
  catch /^NERDTree/
    echo 'Error moving node'
  endtry
endfunction
