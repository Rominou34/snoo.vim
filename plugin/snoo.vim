command! -nargs=* Snoo call GetSubreddit(<f-args>)

" /!\
" @TODO DELETE
" /!\
function! GetMain(...)
	" --- let l:cmd = '%!curl --silent '
	" --- let Callback = function("Echo")

	let l:url = "https://www.reddit.com/r/madeinabyss.json"
	let l:reddit_username = "AyXiit34"

	" --- let l:url = "https://jsonplaceholder.typicode.com/posts/1"
	" --- call snoo#async#get(l:url, Callback)
	" --- let l:cmd .= l:url

	" --- Test buffer
	
	" --- redir => result
	" --- silent execute "%!curl -s ".l:url
	" --- sleep 2000m
	" --- redir END
	" --- redir => result

	let result = system('curl -s '.l:url.' -H "User-Agent: Snoo.vim, used by /u/AyXiit34"')
	sleep 2000m
	if empty(result)
    	echoerr "No output"
  	else
    	call snoo#util#parseSubreddit(result)
    	
    	" --- use "new" instead of "tabnew" below if you prefer split windows instead of tabs
    	" --- tabnew
    	" --- setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    	" --- silent put=result
		" --- syntax keyword testKeyword div
		" --- highlight link testKeyword img
  	endif

	" --- new
	" --- setlocal buftype=nofile
	" --- setlocal noswapfile

	" --- echo "HI"
	" --- :echo l:result
	" --- let json = JSON#parse(l:result)
	" --- for id in json
	"	--- echo id." - "
	" --- endfor
	" --- echo l:result

	call snoo#util#highlight()
endfunction

function! GetSubreddit(...)
	let l:sub = "All"
	if(a:0 > 0)
		let l:sub = a:1
	endif
	let l:url = "https://www.reddit.com/r/"
	let l:url .= l:sub
	let l:url .= ".json"
	let l:reddit_username = "AyXiit34"

	echo "Loading /r/".l:sub." hot posts..."
	let result = system('curl -s '.l:url.' -H "User-Agent: Snoo.vim, used by /u/'.l:reddit_username.'"')
	sleep 2000m
	if empty(result)
		echoerr "No output"
	else
		call snoo#util#parseSubreddit(result, l:sub)
	endif

	call snoo#util#highlight()
endfunction

function! GetPost()
	let l:post_id = expand("<cword>")
	let l:url = "https://www.reddit.com/comments/"
	let l:url .= l:post_id
	let l:url .= ".json"
	let l:reddit_username = "AyXiit34"

	echo "Loading post #".l:post_id."..."
	let result = system('curl -s '.l:url.' -H "User-Agent: Snoo.vim, used by /u/'.l:reddit_username.'"')
	sleep 2000m
	if empty(result)
		echoerr "No output"
	else
		call snoo#util#parsePost(result)
	endif

	call snoo#util#highlightPost()
endfunction