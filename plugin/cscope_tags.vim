" File:          cscope_tags.vim
" Author:        Jerry
" Version:       0.1
" Last Modified: Feb. 15, 2018
"
" Overview
" ------------
"
" Preparation
" ------------
" If you don't know about cscope, see:
" :help cscope
" http://cscope.sourceforge.net/
"
if !exists('g:cscope_tags_cstags_path')
  let g:cscope_tags_cstags_path=["./", "./cstags/"]
endif

function! s:find_cscope_file()
	for path in g:cscope_tags_cstags_path
		let path = path . "cscope.out"
		if filereadable(path)
			return path
		endif
	endfor

	return ""
endfunction

function! s:find_tags_file()
	for path in g:cscope_tags_cstags_path
		let path = path . "tags"
		if filereadable(path)
			return path
		endif
	endfor

	return ""
endfunction

function! s:cscope_init()
	if !has("cscope")
		return 0
	endif

	let cscope_path = s:find_cscope_file()
	if cscope_path == ""
		return 0
	endif

	set nocsverb
	execute "cs add " . cscope_path
	if cscope_path != "./cscope.out" || cscope_path != "cscope.out"
		set cscoperelative
	endif
	set nocscoperelative
	set cscopequickfix=s-,c-,e-
	set csto=0
	set cst
	set csverb
endfunction

function! s:tags_init()
	let tags_path = s:find_tags_file()
	if tags_path == "" ||  tags_path == "./tags" || tags_path == "tags"
		let &tags = getcwd() . "/tags"
		return
	endif
	let &tags = tags_path
	set tagrelative
endfunction

command! -nargs=* Cinit call s:cscope_init(<f-args>)
command! -nargs=* Tinit call s:tags_init(<f-args>)

"   function! s:simple_cscope(...)
"   endfunction
"
"   command! -nargs=* f call s:simple_cscope(<f-args>)

" "Symbols":  Find this C symbol
nmap cs :cs f s <C-R>=expand("<cword>")<CR>
" "Defines":  Find this definition
nmap cg :cs f g <C-R>=expand("<cword>")<CR>
" "Calls":    Find functions called by this function
nmap cd :cs f d <C-R>=expand("<cword>")<CR>
" "Globals":  Find functions calling this function
nmap cc :cs f c <C-R>=expand("<cword>")<CR>
" "Texts":    Find this text string
nmap ct :cs f t <C-R>=expand("<cword>")<CR>
" "Egrep":    Find this egrep pattern
nmap ce :cs f e <C-R>=expand("<cword>")<CR>
" "File":     Find this file
nmap cf :cs f f <C-R>=expand("<cword>")<CR>
" "Includes": Find files #including this file
nmap ci :cs f i <C-R>=expand("<cword>")<CR>

call s:cscope_init()
call s:tags_init()
nmap <c-.> <esc>:cn<CR>
nmap <c-,> <esc>:cp<CR>

" 为了阅读代码跳转方便，增加两个快捷方式
" noremap  <C-Right>   <C-]>
" noremap  <C-Left>    <C-o>
" inoremap <C-Right>   <C-O><C-]>
" inoremap <C-Left>    <C-O><C-o>
" 按下<C-Right>键，跳转到其定义处
nmap <silent> <C-Right>      <C-]>
imap <silent> <C-Right> <C-O><C-]>
" 按下<C-Left>键，返回刚才跳出的地方
nmap <silent> <C-Left>      <C-O>
imap <silent> <C-Left> <C-O><C-O>

" 预览函数的快捷键
nmap <F9>   <C-W>g}
nmap <F12>  <C-W>g]
" 为了修正preview窗口的绝对路径的问题
autocmd Bufenter *.[ch] exe "cd ."

" 针对内核，有时需要gf一下文件，设置文件的路径
" set path= .,./include,/usr/include,/usr/src/linux/include,,
" let &path = &path . "," . substitute($INCL, ';', ',', 'g')
" let &path = &path . "," . getcwd()."/arch/arm/plat-s3c/include". ","
set path=.
set path+=arch/arm/include/
set path+=arch/arm/mach-mmp/include
set path+=arch/arm/mach-pxa/include
set path+=include/
"let &path = &path . "," . getcwd()."/arch/arm/include/asm/". ","
"let &path = &path . "," . getcwd()."/arch/arm/include/generated/asm/". ","
"let &path = &path . "," . getcwd()."/arch/arm/mach-mmp/include". ","
"let &path = &path . "," . getcwd()."/arch/arm/mach-pxa/include". ","
"let &path = &path . "," . getcwd()."/arch/arm/include". ","
"let &path = &path . "," . getcwd()."/include". ","
"let &path = &path . "," . getcwd()."/include/asm-generic/". ","
"set path+=/usr/src/linux-2.6.26-gentoo-r4/include

" 普通模式下面在关键字上按;查看函数原型
nmap <silent> ;      :ptag <C-R>=expand("<cword>")<CR><CR>

" ------------------------------------------------------------------------------
" 关于使用taglist插件的一些设置
" ------------------------------------------------------------------------------
function! s:taglist_init()
	nnoremap <silent> <F7> :TlistUpdate<CR>
	nnoremap <silent> <F8> :TlistToggle<CR>
	" 防止taglist插件，弄乱屏幕
	if has('eval')
	     let Tlist_Inc_Winwidth=0
	endif

	let Tlist_Show_One_File = 1            "不同时显示多个文件的tag，只显示当前文件的
	let Tlist_Exit_OnlyWindow = 1          "如果taglist窗口是最后一个窗口，则退出vim
	let Tlist_Use_Right_Window = 0         "在右侧窗口中显示taglist窗口
	let Tlist_Show_Menu = 1
	let Tlist_Process_File_Always = 1
	let Tlist_File_Fold_Auto_Close = 1
	let Tlist_Ctags_Cmd = "/usr/bin/ctags"
	let Tlist_Sort_Type = "name"
	let Tlist_Show_Menu = 1
	let Tlist_Show_One_File = 1
	let Tlist_Exit_OnlyWindow = 1
	let Tlist_Use_Right_Window = 1
	let Tlist_Use_SingleClick = 1
endfunction

" ------------------------------------------------------------------------------
" 关于使用tagbar插件的一些设置
" ------------------------------------------------------------------------------
function! s:tagbar_init()
	let g:tagbar_left = 1
	let g:tagbar_width = 30
	"let g:tagbar_expand = 1
	nnoremap <silent> <F8> :TagbarToggle<CR>
endfunction

call s:tagbar_init()
" vim:set ts=4 sw=4 filetype=vim: