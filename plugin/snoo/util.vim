function! snoo#util#highlight()
	" Beautify the window with syntax highlighting.
	if has("syntax") && exists("g:syntax_on")

		" highlight default link twitterUser Identifier
		highlight default link twitterTime String
		highlight default link twitterTimeBar Ignore
		highlight default link twitterTitle Title
		highlight default link twitterTitleStar Ignore
		highlight default link twitterLink Underlined
		highlight default link twitterReply Label

		syntax match postScoru /\[[0-9]*\]/

		syntax match postScore /[0-9]* points/
		syntax match numComments /\([0-9]* comments\)/
		syntax match selfLabel /\(self\)/
		syntax match subredditName /\/r\/[a-zA-Z0-9_.-]*/
		syntax match subredditTitle /===.*===/
		syntax match nsfwLabel /NSFW/

		highlight default link postScore Label
		highlight default link numComments Comment
		highlight default link selfLabel Comment
		highlight default link subredditName Identifier
		highlight default link subredditTitle Title
		highlight default link nsfwLabel Title
	endif
endfunction

function! snoo#util#highlightPost()
	" Beautify the window with syntax highlighting.
	if has("syntax") && exists("g:syntax_on")

		syntax match postTitle /===.*===/
		syntax match userName /\/u\/[a-zA-Z0-9_.-]*/
		syntax match closedName /\[\.\.\.\]/
		syntax match closedComment /\[Closed comment\]/

		highlight default link postTitle Title
		highlight default link userName Identifier
		highlight default link closedName Comment
		highlight default link closedComment Comment
	endif
endfunction