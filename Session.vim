let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/clones/toraritte.github.io
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
argglobal
%argdel
set stal=2
tabnew
tabnew
tabrewind
edit posts/2020-07-18-how-to-implement-electronic-signature-web-app.md
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 96 + 97) / 194)
exe 'vert 2resize ' . ((&columns * 97 + 97) / 194)
argglobal
setlocal fdm=expr
setlocal fde=MarkdownFold()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=20
setlocal fen
1
normal! zo
9
normal! zo
let s:l = 20 - ((19 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
20
normal! 08|
lcd ~/clones/toraritte.github.io
wincmd w
argglobal
if bufexists("~/clones/toraritte.github.io/index.md") | buffer ~/clones/toraritte.github.io/index.md | else | edit ~/clones/toraritte.github.io/index.md | endif
setlocal fdm=expr
setlocal fde=MarkdownFold()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=20
setlocal fen
1
normal! zo
let s:l = 23 - ((1 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
23
normal! 0128|
wincmd w
exe 'vert 1resize ' . ((&columns * 96 + 97) / 194)
exe 'vert 2resize ' . ((&columns * 97 + 97) / 194)
tabnext
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
terminal ++curwin ++cols=194 ++rows=50 
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 2 - ((1 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 013|
lcd ~/clones/toraritte.github.io
tabnext
edit ~/clones/toraritte.github.io/posts/2020-08-05-development-environmnets-with-nix-shell-and-niv.md
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 96 + 97) / 194)
exe 'vert 2resize ' . ((&columns * 97 + 97) / 194)
argglobal
setlocal fdm=expr
setlocal fde=MarkdownFold()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 1 - ((0 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 063|
lcd ~/clones/toraritte.github.io
wincmd w
argglobal
if bufexists("~/clones/toraritte.github.io/index.md") | buffer ~/clones/toraritte.github.io/index.md | else | edit ~/clones/toraritte.github.io/index.md | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 23 - ((22 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
23
normal! 0
lcd ~/clones/toraritte.github.io
wincmd w
exe 'vert 1resize ' . ((&columns * 96 + 97) / 194)
exe 'vert 2resize ' . ((&columns * 97 + 97) / 194)
tabnext 3
set stal=1
badd +1 ~/clones/toraritte.github.io/posts/2020-07-18-how-to-implement-electronic-signature-web-app.md
badd +23 ~/clones/toraritte.github.io/index.md
badd +1 ~/clones/toraritte.github.io/posts/2020-08-05-development-environmnets-with-nix-shell-and-niv.md
badd +1 ~/clones/toraritte.github.io/Untitled_win1.html
badd +1 ~/clones/toraritte.github.io/Untitled_win2.html
badd +69 ~/clones/toraritte.github.io/Diff.html
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOSc
set winminheight=1 winminwidth=1
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
