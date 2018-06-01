command! -nargs=* Snoo call GetSubreddit(<f-args>)

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