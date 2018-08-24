command! -nargs=* Snoo call GetSubreddit(<f-args>)
command! -nargs=* SnooSearch call SearchSubreddit(<f-args>)

scriptencoding utf-8
set encoding=utf-8

function! GetSubreddit(...)
	let l:sub = "All"
	if(a:0 > 0)
		let l:sub = a:1
	endif
	let l:url = "https://www.reddit.com/r/"
	let l:url .= l:sub
	let l:postkind = "hot"
	
	if(a:0 > 1)
		if(a:2 == "top")
			let l:url .= "/top.json?t=all"
			let l:postkind = "top"
		elseif(a:2 == "new")
			let l:url .= "/new.json"
			let l:postkind = "new"
		endif
	else
		let l:url .= ".json"
	endif

	echo "Loading /r/".l:sub." ".l:postkind." posts..."

	let l:reddit_username = "AyXiit34"
	let result = system('curl -s -L '.l:url.' -H "User-Agent: Snoo.vim, used by /u/'.l:reddit_username.'"')
	sleep 2000m
	if empty(result)
		echoerr "No output"
	else
		call snoo#parser#parseSubreddit(result, l:sub)
	endif

	call snoo#util#highlight()
endfunction

function! SearchSubreddit(...)
	let l:sub = "All"
	let l:search = ""
	if(a:0 > 0)
		let l:sub = a:1
		let l:search = a:2
	else
		let l:search = a:1
	endif
	let l:url = "https://www.reddit.com/r/"
	let l:url .= l:sub
	let l:url .= "/search.json?q="
	let l:url .= l:search
	let l:url .= "&restrict_sr=on&sort=relevance&t=all"

	echo "Loading /r/".l:sub." posts..."

	let l:reddit_username = "AyXiit34"
	let result = system('curl -s -L "'.l:url.'" -H "User-Agent: Snoo.vim, used by /u/'.l:reddit_username.'"')
	sleep 2000m
	if empty(result)
		echoerr "No output"
	else
		call snoo#parser#parseSubreddit(result, l:sub)
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
		call snoo#parser#parsePost(result)
	endif

	call snoo#util#highlightPost()
endfunction