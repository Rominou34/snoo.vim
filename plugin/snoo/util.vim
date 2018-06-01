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

		syntax match postScore /^[0-9]*/
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






" BEYOND THIS COMMENT IT'S NOT TRULY UTILE







function! s:tempname() abort
	return tr(tempname(),'\','/')
endfunction

function! s:base_command() abort
	if executable("curl")
		return "curl"
	endif
	" TODO: for Windows?
	throw "snoo.vim: curl does not found."
endfunction

function! s:quoted(str) abort
	let q = (&shellxquote == '"' ?  "'" : '"')
	return q . a:str . q
endfunction

function! s:make_header_args(settings, option) abort
	if !has_key(a:settings, "headers")
		let a:settings.headers = {}
	endif
	let headers = a:settings.headers
	" Complete header
	if has_key(a:settings, 'contentType')
		let headers['Content-Type'] = a:settings.contentType
	endif
	" Convert to args
	let args = ''
	for [key, value] in items(headers)
		if s:Prelude.is_windows()
			let value = substitute(value, '"', '"""', 'g')
		endif
		let args .= " " . a:option . " " . s:quoted(key . ": " . value)
	endfor
	return args
endfunction

function! s:add_option(settings, opt, prefix) abort
	if has_key(a:settings, a:opt)
		return " " . a:prefix . " " . a:settings[a:opt]
	endif
	return ""
endfunction

function! s:auth_option(settings) abort
	if !has_key(a:settings, 'username')
		return ""
	endif
	let auth = a:settings.username . ':' . get(a:settings, 'password', '')
	if has_key(a:settings, 'authMethod')
		if index(['basic', 'digest', 'ntlm', 'negotiate'], a:settings.authMethod) == -1
			throw 'curl.vim: Invalid authorization method: ' . a:settings.authMethod
		endif
		let method = a:settings.authMethod
	else
		let method = "anyauth"
	endif
	return ' --' . method . ' --user ' . s:quoted(auth)
endfunction

function! s:postdata(data) abort
	if s:Prelude.is_dict(a:data)
		return [s:http.encodeURI(a:data)]
	elseif s:Prelude.is_list(a:data)
		return a:data
	else
		return split(a:data, "\n")
	endif
endfunction

function! s:make_url(url, settings) abort
	if has_key(a:settings, 'param')
		let param = a:settings.param
		if s:Prelude.is_dict(param)
			let getdatastr = s:http.encodeURI(param)
		else
			let getdatastr = param
		endif
		if strlen(getdatastr)
			return a:url .= '?' . getdatastr
		endif
	endif
	return a:url
endfunction

function! snoo#util#make_command(url, settings) abort
	let command = s:base_command()

	" output files
	let a:settings._file = {
				\ 'header': s:tempname(),
				\ 'body': get(a:settings, "outputFile", s:tempname())
				\ }
	let command .= ' --dump-header ' . s:quoted(a:settings._file.header)
	let command .= ' --output ' . s:quoted(a:settings._file.body)
	if has_key(a:settings, 'data')
		let a:settings._file.post = s:tempname()
		call writefile(s:postdata(a:settings.data), a:settings._file.post, 'b')
		let command .= ' --data-binary @' . s:quoted(a:settings._file.post)
	endif
	if has_key(a:settings, 'gzipDecompress') && a:settings.gzipDecompress
		let command .= ' --compressed'
	endif

	" basic
	let command .= ' -L' " location
	let command .= ' -s' " silent

	" network
	let command .= ' -k' " unsafe SSL
	let command .= s:add_option(a:settings, 'method', '-X')
	let command .= s:add_option(a:settings, 'maxRedirect', '--max-redirs')
	let command .= s:add_option(a:settings, 'timeout', '--max-time')
	let command .= s:add_option(a:settings, 'retry', '--retry')
	let command .= s:make_header_args(a:settings, '-H')
	let command .= s:auth_option(a:settings)

	" add URL
	let command .= ' ' . s:quoted(s:make_url(a:url, a:settings))
	return command
endfunction

function! s:readfile(file) abort
	if !filereadable(a:file)
		throw "snoo.vim: File does not exists: " . a:file
	endif
	return join(readfile(a:file, 'b'), "\n")
endfunction

function! s:read_header(headerfile) abort
	let headerstr = s:readfile(a:headerfile)
	let header_chunks = split(headerstr, "\r\n\r\n")
	return split(get(header_chunks, -1, ''), "\r\n")
endfunction

function! snoo#util#make_response(settings) abort
	let header = s:read_header(a:settings._file.header)
	let content = s:readfile(a:settings._file.body)

	for file in values(a:settings._file)
		if filereadable(file)
			call delete(file)
		endif
	endfor

	let response = {
				\   'header' : header,
				\   'content': content,
				\   'status': 0,
				\   'statusText': '',
				\   'success': 0,
				\ }

	if !empty(header)
		let status_line = get(header, 0)
		let matched = matchlist(status_line, '^HTTP/1\.\d\s\+\(\d\+\)\s\+\(.*\)')
		if !empty(matched)
			let [status, statusText] = matched[1 : 2]
			let response.status = status - 0
			let response.statusText = statusText
			let response.success = status =~# '^2'
			call remove(header, 0)
		endif
	endif
	return response
endfunction