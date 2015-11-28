WOOOO DOTFILES
==============

My dotfiles. I don't customize ❤❤❤❤ out of my tools. If they don't fit me without too many customizations, I switch to something else. Or I try to adapt. Heavily customized and plugin-ized applications cause pain when switching systems and make me uncomfortable when using someone else's computer.

Oh hey, also my install script is in python because I hate shell scripts.

Run `install.py` and it hopefully sets correct symbolic links to stuff. It does not try to overwrite files.

tmux
----
It's `^A` instead of `^B`, and `^Left` `^Right` to switch windows, mostly. Some colours. A clock, unsure what for.

git
---
My name and e-mail. Some colours, I guess.

zsh
---
I'm not a shell junkie. This contains some of @eevee `.zshrc`, as a "sane default". I switched to this from `oh-my-zsh` which kind of violated my "do not pluginize too much" rule. Cool project though, check them out if you want something fancy.

History is shared, but not for up/down. 

Window title, unsure if it works though.

Noglob for `find` and `wget`.

Some cool (?) aliases:
* `rcp`, sometimes I want to see progress when I copy a file. Or my terminal scrolling quickly when I copy bunch of them. Anyone knows how to make it do "progress" but for "entire operation"?
* `igrep=grep -i` - `-i` sets case insensitive.
* `findhere` - find in current dir with name, case insensitive.
* `sedpq` - get n-th line from multiline output. Cool if `pgrep` returns more than one process.
* `fst` - get first line from multiline output

Some functions:
* `activate_venv()` - find a virtualenv in current dir and activate it (asks first).
