if !exists("g:snoo#pool")
	let g:snoo#pool = {}
endif

function! s:execute_callback() abort
	for id in keys(g:snoo#pool)
		let obj = g:snoo#pool[id]
		let [st, _]= obj.process.checkpid()
		if st != 'run'
			let res = snoo#util#make_response(obj.settings)
			call obj.callback(res)
			call remove(g:snoo#pool, id)
		endif
	endfor
	if len(g:snoo#pool) == 0
		augroup plugin-snoo-async
			autocmd!
		augroup END
	endif
endfunction

function! s:async(command, callback, settings) abort
	if type(a:callback) != 2 " Function
		throw " snoo.vim: Callback is not a function
	endif
	echo a:command
	let proc = vimproc#system(a:command)
	let id = localtime()
	let g:snoo#pool[id] = {
		\ "callback": a:callback,
		\ "settings": a:settings,
		\ "process": proc,
		\ }
	augroup plugin-snoo-async
		autocmd! CursorHold,CursorHoldI * call s:execute_callback()
	augroup END
endfunction

function snoo#async#request(url, callback, settings) abort
	let command = snoo#util#make_command(a:url, a:settings)
	call s:async(command, a:callback, a:settings)
endfunction

function snoo#async#get(url, callback, ...) abort
	if len(a:000) > 0 && type(a:1) == type({})
		let settings = a:1
	else
		let settings = {}
	endif
	let settings.method = "GET"
	return snoo#async#request(a:url, a:callback, settings)
endfunction