# Snoo.vim

Browse [Reddit](https://www.reddit.com) inside Vim

## Usage

* Open the front page of a subreddit using `:Snoo [subreddit]`
* Use `Leader + g` on a post ID to display it

## Installation

The strength of snoo.vim is that it doesn't require a special installation of vim running Python, 20 000+ external libraries or things like that (only vim 8.*):
* The data is loaded from Reddit via the public '.json' API
* It is then parsed by the json_decode() function

The only drawback is that you can only read posts and comments and can't engage, as account login requires oAuth authentification

#### Pathogen

```bash
git clone https://github.com/Rominou34/snoo.vim ~/.vim/bundle/snoo.vim
```
