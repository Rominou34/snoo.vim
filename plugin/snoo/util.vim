function! snoo#util#highlight()
	" Beautify the window with syntax highlighting.
	if has("syntax") && exists("g:syntax_on")

		syntax match postScore /[0-9]* points/
		syntax match numComments /\([0-9]* comments\)/
		syntax match selfLabel /\(self\)/
		syntax match postuserName /\/u\/[a-zA-Z0-9_.-]*/
		syntax match subredditName /\/r\/[a-zA-Z0-9_.-]*/
		syntax match subredditTitle /===.*===/
		syntax match nsfwLabel /NSFW/

		highlight default link postScore Label
		highlight default link numComments Comment
		highlight default link selfLabel Comment
		highlight default link postuserName Label
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
		syntax match userScore /[0-9]* pts/
		syntax match closedName /\[\.\.\.\]/
		syntax match closedComment /\[Closed comment\]/
		syntax match editedLabel /\[edited\]/
		syntax match modLabel /\[MOD\]/

		highlight default link postTitle Title
		highlight default link userName Identifier
		highlight default link userScore Title
		highlight default link closedName Comment
		highlight default link closedComment Comment
		highlight default link editedLabel Title
		highlight default link modLabel Label

	endif
endfunction