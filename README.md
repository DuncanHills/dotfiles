dotfiles
========

Instructions
------------
1. Back up your dotfiles.
1. Clone this repo: `git clone https://github.com/ascrane/dotfiles.git`
1. `cd dotfiles` then `make install` to install the contents in your home directory as symlinks (or `make help` for other options).

Optional Files
--------------
Create these files, and they will automagically work.
- `~/.bash_privates` — You can make custom username and hostname aliases here, if you are using `.bash_ps1` (see that file for more detail)
- `~/.git_privates` — Place your personal git configuration options here (username, email, etc.)

Customization
-------------
You can fork this repo and tailor it to your needs.
### New dotfiles
Just commit any new dotfiles to your repo and run `make install` to put them to work.
### Moving/removing dotfiles
`git rm` or `git mv` them, then run `make clean-dead`.
### Modules and subdirectories
If you have a directory of files that needs to co-exist with unmanaged files, add that directory and those files to your repo, then append the directory name to the `modules` file. Modules won't be symlinked, but the files they contain will. Modules can be an arbitrary depth, but nesting modules does not currently work.
