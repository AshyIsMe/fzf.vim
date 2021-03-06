" Copyright (c) 2015 Junegunn Choi
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

let s:cpo_save = &cpo
set cpo&vim

let g:fzf#vim#default_layout = {'down': '~40%'}

function! s:defs(commands)
  let prefix = get(g:, 'fzf_command_prefix', '')
  if prefix =~# '^[^A-Z]'
    echoerr 'g:fzf_command_prefix must start with an uppercase letter'
    return
  endif
  for command in a:commands
    execute substitute(command, '\ze\C[A-Z]', prefix, '')
  endfor
endfunction

call s:defs([
\'command! -bang -nargs=? -complete=dir Files  call fzf#vim#files(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=? GitFiles             call fzf#vim#gitfiles(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=? GFiles               call fzf#vim#gitfiles(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang Buffers                       call fzf#vim#buffers(fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=* Lines                call fzf#vim#lines(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=* BLines               call fzf#vim#buffer_lines(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang Colors                        call fzf#vim#colors(fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=1 -complete=dir Locate call fzf#vim#locate(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=* Ag                   call fzf#vim#ag(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=* AgHistory            call fzf#vim#aghistory(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=* Tags                 call fzf#vim#tags(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=* BTags                call fzf#vim#buffer_tags(<q-args>, fzf#vim#layout(<bang>0))',
\'command! -bang Snippets                      call fzf#vim#snippets(fzf#vim#layout(<bang>0))',
\'command! -bang Commands                      call fzf#vim#commands(fzf#vim#layout(<bang>0))',
\'command! -bang Marks                         call fzf#vim#marks(fzf#vim#layout(<bang>0))',
\'command! -bang Helptags                      call fzf#vim#helptags(fzf#vim#layout(<bang>0))',
\'command! -bang Windows                       call fzf#vim#windows(fzf#vim#layout(<bang>0))',
\'command! -bang Commits                       call fzf#vim#commits(fzf#vim#layout(<bang>0))',
\'command! -bang BCommits                      call fzf#vim#buffer_commits(fzf#vim#layout(<bang>0))',
\'command! -bang Maps                          call fzf#vim#maps("n", fzf#vim#layout(<bang>0))',
\'command! -bang Filetypes                     call fzf#vim#filetypes(fzf#vim#layout(<bang>0))',
\'command! -bang -nargs=* History              call s:history(<q-args>, <bang>0)'])

function! s:history(arg, bang)
  let bang = a:bang || a:arg[len(a:arg)-1] == '!'
  let ext = fzf#vim#layout(bang)
  if a:arg[0] == ':'
    call fzf#vim#command_history(ext)
  elseif a:arg[0] == '/'
    call fzf#vim#search_history(ext)
  else
    call fzf#vim#history(ext)
  endif
endfunction

function! fzf#complete(...)
  return call('fzf#vim#complete', a:000)
endfunction

if has('nvim') && get(g:, 'fzf_nvim_statusline', 1)
  function! s:fzf_restore_colors()
    if exists('#User#FzfStatusLine')
      doautocmd User FzfStatusLine
    else
      if $TERM !~ "256color"
        highlight fzf1 ctermfg=1 ctermbg=8 guifg=#E12672 guibg=#565656
        highlight fzf2 ctermfg=2 ctermbg=8 guifg=#BCDDBD guibg=#565656
        highlight fzf3 ctermfg=7 ctermbg=8 guifg=#D9D9D9 guibg=#565656
      else
        highlight fzf1 ctermfg=161 ctermbg=238 guifg=#E12672 guibg=#565656
        highlight fzf2 ctermfg=151 ctermbg=238 guifg=#BCDDBD guibg=#565656
        highlight fzf3 ctermfg=252 ctermbg=238 guifg=#D9D9D9 guibg=#565656
      endif
      setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
    endif
  endfunction

  function! s:fzf_nvim_term()
    if get(w:, 'airline_active', 0)
      let w:airline_disabled = 1
      autocmd BufWinLeave <buffer> let w:airline_disabled = 0
    endif
    autocmd WinEnter,ColorScheme <buffer> call s:fzf_restore_colors()

    setlocal nospell
    call s:fzf_restore_colors()
  endfunction

  augroup _fzf_statusline
    autocmd!
    autocmd FileType fzf call s:fzf_nvim_term()
  augroup END
endif

let g:fzf#vim#buffers = {}
augroup fzf_buffers
  autocmd!
  if exists('*reltimefloat')
    autocmd BufWinEnter,WinEnter * let g:fzf#vim#buffers[bufnr('')] = reltimefloat(reltime())
  else
    autocmd BufWinEnter,WinEnter * let g:fzf#vim#buffers[bufnr('')] = localtime()
  endif
  autocmd BufDelete * silent! call remove(g:fzf#vim#buffers, expand('<abuf>'))
augroup END

inoremap <expr> <plug>(fzf-complete-word)        fzf#vim#complete#word()
inoremap <expr> <plug>(fzf-complete-path)        fzf#vim#complete#path("find . -path '*/\.*' -prune -o -print \| sed '1d;s:^..::'")
inoremap <expr> <plug>(fzf-complete-file)        fzf#vim#complete#path("find . -path '*/\.*' -prune -o -type f -print -o -type l -print \| sed 's:^..::'")
inoremap <expr> <plug>(fzf-complete-file-ag)     fzf#vim#complete#path("ag -l -g ''")
inoremap <expr> <plug>(fzf-complete-line)        fzf#vim#complete#line()
inoremap <expr> <plug>(fzf-complete-buffer-line) fzf#vim#complete#buffer_line()

nnoremap <silent> <plug>(fzf-maps-n) :<c-u>call fzf#vim#maps('n', fzf#vim#layout(0))<cr>
inoremap <silent> <plug>(fzf-maps-i) <c-o>:call fzf#vim#maps('i', fzf#vim#layout(0))<cr>
xnoremap <silent> <plug>(fzf-maps-x) :<c-u>call fzf#vim#maps('x', fzf#vim#layout(0))<cr>
onoremap <silent> <plug>(fzf-maps-o) <c-c>:<c-u>call fzf#vim#maps('o', fzf#vim#layout(0))<cr>

let &cpo = s:cpo_save
unlet s:cpo_save

