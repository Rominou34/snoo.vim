function! snoo#parser#parseSubreddit(res, subreddit)
	tabnew
	setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified

	nnoremap <buffer> <Leader>g :call GetPost()<CR>

	" put = a:res
	let l:subreddit_title = "=== "
	let l:subreddit_title .= a:subreddit
	let l:subreddit_title .= " ==="

	silent put = l:subreddit_title

	let l:empty = ""
	silent put = l:empty
	silent put = l:empty

	let json = json_decode(a:res)
	if(has_key(json, 'data'))
		if(has_key(json['data'],'children'))
			for child in json['data']['children']
				call snoo#parser#parsePostLine(child.data)
				" silent put = child['data']['title']
			endfor
		endif
	endif

	" We jump to the top of the page
	execute "normal! gg"
endfunction

function! snoo#parser#parsePostLine(postLine)
	" First line: Score and Title post
	let l:firstline = a:postLine.id
	let l:firstline .= "    "
	let l:firstline .= a:postLine.title
	if (a:postLine.is_self)
		let l:firstline .= "  (self)"
	endif
	silent put = l:firstline

	" Selonde line: Number of comments, author, subreddit and NSFW badge
	let l:secondline = "          "
	let l:secondline .= a:postLine.score
	let l:secondline .= " points    ("
	let l:secondline .= a:postLine.num_comments
	let l:secondline .= " comments)    by /u/"
	let l:secondline .= a:postLine.author
	let l:secondline .= " in /r/"
	let l:secondline .= a:postLine.subreddit
	if (a:postLine.over_18)
		let l:secondline .= "    NSFW"
	endif
	silent put = l:secondline

	" Jump a line between posts
	let l:thirdline = ""
	silent put = l:thirdline
endfunction

function! snoo#parser#parsePost(post)
	tabnew
	setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified

	let json = json_decode(a:post)
	let l:maincomment = json[0].data.children[0]
	let l:newline = ""

	" We first display the header with the post title
	let l:header = "=== "
	let l:header .= l:maincomment.data.title
	let l:header .= " ==="
	silent put = l:header

	" If the post has a selftext we display it
	if has_key(l:maincomment.data, 'selftext')
		silent put = l:newline
		let l:border = "********************"
		silent put = l:border
		silent put = l:newline
		
		let l:post = l:maincomment.data.selftext
		silent put = l:post

		silent put = l:newline
		silent put = l:border
	endif

	silent put = l:newline

	let l:authorline = "Posted by /u/"
	let l:authorline .= l:maincomment.data.author

	" We display a label if the author is a moderator
	if type(l:maincomment.data.distinguished) == 1
		if l:maincomment.data.distinguished == "moderator"
			let l:authorline .= " [MOD] "
		endif
	endif

	" If the comment was edited, we put a label '[edited]'
	" The value of 'edited' is false if the comment is not edited, else it's a float indicating the time
	if type(l:maincomment.data.edited) == 5
		let l:authorline .= " [edited]"
	endif

	let l:authorline .= "   "
	let l:authorline .= l:maincomment.data.score
	let l:authorline .= " pts"

	silent put = l:authorline
	silent put = l:newline

	let l:commentsTitle = "=== COMMENTS ==="
	silent put = l:commentsTitle
	silent put = l:newline

	" We display the comments
	let l:comments = json[1].data.children
	call snoo#parser#parseComments(l:comments)

	" We jump to the top of the page
	execute "normal! gg"
endfunction

function! snoo#parser#parseComments(comments)
	for comment in a:comments
		call snoo#parser#displayComment(comment, 0)
	endfor
	call snoo#util#highlightPost()
endfunction

function! snoo#parser#displayComment(comment, depth)
	let l:depth = a:comment.data.depth
	let l:leftpad = ""
	let l:authorline = ""
	let i = 0
	while i <= l:depth
		let l:authorline .= "    |"
		let l:leftpad .= "    |"
		let i += 1
	endwhile

	" We only jump lines for the comments which don't have childs
	" Or else a depth of 5 comments will give us 5 new lines
	let l:jumpnewline = 1

	" If it has 'author' and 'body' it is an open comment
	if has_key(a:comment.data, 'author') && has_key(a:comment.data, 'body')
		" First line (username and score)
		let l:authorline .= "/u/"
		let l:authorline .= a:comment.data.author

		" We display a label if the author is a moderator
		if type(a:comment.data.distinguished) == 1
			if a:comment.data.distinguished == "moderator"
				let l:authorline .= " [MOD] "
			endif
		endif

		" If the comment was edited, we put a label '[edited]'
		" The value of 'edited' is false if the comment is not edited, else it's a float indicating the time
		if type(a:comment.data.edited) == 5
			let l:authorline .= " [edited]"
		endif

		let l:authorline .= "   "
		let l:authorline .= a:comment.data.score
		let l:authorline .= " pts"

		silent put = l:authorline

		" Second line (comment)
		let l:comment = l:leftpad
		let l:comment .= a:comment.data.body
		silent put = l:comment

		" Replies
		if type(a:comment.data.replies) == type({})
			if has_key(a:comment.data.replies, 'data')
				if has_key(a:comment.data.replies.data, 'children')
					if len(a:comment.data.replies.data.children) > 0
						let l:jumpnewline = 0
						for child in a:comment.data.replies.data.children
							call snoo#parser#displayComment(child, l:depth+1)
						endfor
					endif
				endif
			endif
		endif
	" Else it is a close comment (on Reddit you have to click on these to deploy them)
	else
		let l:closedauthor = l:leftpad
		let l:closedauthor .= "[.....]"
		let l:closedcomment = l:leftpad
		let l:closedcomment .= "[Closed comment]"
		silent put = l:closedauthor
		silent put = l:closedcomment
	endif

	" If we can jump a line we do it
	if l:jumpnewline == 1
		let l:newline = ""
		silent put = l:newline
	endif
endfunction