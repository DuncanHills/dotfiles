# -----------------------------------------------------------------------------
# Setup
#

IGNORE_FILE = ignores
PACKAGES_FILE = packages
MODULES_FILE = modules

SHELL = /bin/bash
CURDIR ?= $(.CURDIR)
LN_FLAGS = -sfn
CLR = \033[32;01m
NO_CLR = \033[0m

# find interesting dotfiles, ignore things in ignores and modules files
SYMLINKS := $(shell find . -mindepth 1 -maxdepth 1 -name '.*' \
-exec basename {} \; | \
$$([[ -n $$(cat $(IGNORE_FILE)) ]] \
&& echo "grep -vFx -f $(IGNORE_FILE)" \
|| echo "cat -") | \
$$([[ -n $$(cat $(MODULES_FILE)) ]] \
&& echo "grep -vFx -f $(MODULES_FILE)" \
|| echo "cat -") | \
tr "\n" " ")

# get packages list
PACKAGES := $(shell cat $(PACKAGES_FILE) | tr "\n" " ")

# get modules list
MODULES := $(shell cat $(MODULES_FILE) | tr "\n" " ")

# OS-specific setup

OS = $(shell uname -s)
ifeq ($(OS),Darwin)
	INSTALL_PACKAGES = brew install
	# Sublime Text
	ST_PATH = $(HOME)/Library/Application Support/Sublime Text 3/Packages/User
	ST_FILES = "Package\ Control.sublime-settings" "Preferences.sublime-settings"
else ifeq ($(OS),Linux)
	ifeq ($(shell which dpkg),)
		INSTALL_PACKAGES = apt-get install --assume-yes
	else ifeq ($(shell which yum),)
		INSTALL_PACKAGES = apt-get install --assumeyes
	endif
endif

# fake (non-file) targets
.PHONY: all install clean check-dead clean-dead update $(SYMLINKS) $(MODULES) \
packages

# -----------------------------------------------------------------------------
# Help
#

help:
	@echo -e "Makefile for installing dotfiles"
	@echo -e
	@echo -e "Create symlinks:"
	@echo -e " $(CLR)make install$(NO_CLR)       Symlink dotfiles and modules"
	@echo -e
	@echo -e "Install vim and shell extras:"
	@echo -e " $(CLR)make vim-extras$(NO_CLR)    Install vim bundles"
	@echo -e " $(CLR)make zsh-extras$(NO_CLR)    Install prezto and z"
	@echo -e " $(CLR)make prezto$(NO_CLR)        Install prezto"
	@echo -e " $(CLR)make z$(NO_CLR)             Install z"
	@echo -e
	@echo -e "Install common packages:"
	@echo -e " $(CLR)make packages$(NO_CLR)      Install default packages"
	@echo -e
	@echo -e "Install Sublime Text config:"
	@echo -e " $(CLR)make subl$(NO_CLR)          Install Sublime Text config"
	@echo -e
	@echo -e "Maintenance:"
	@echo -e " $(CLR)make clean$(NO_CLR)         Delete vim bundles"
	@echo -e " $(CLR)make check-dead$(NO_CLR)    Print dead symlinks"
	@echo -e " $(CLR)make clean-dead$(NO_CLR)    Delete dead symlinks"
	@echo -e " $(CLR)make update$(NO_CLR)        Alias for git pull --rebase"
	@echo -e " $(CLR)make rehash$(NO_CLR)        Source .zshrc in all tmux \
	panes"
	@echo -e
	@echo -e "Useful aliases:"
	@echo -e " $(CLR)make all$(NO_CLR) install vim-extras zsh-extras"

# -----------------------------------------------------------------------------
# Targets
#

# Shell environment

all: install vim-extras

clean:
	rm -rf -- $(CURDIR)/dot.vim/bundle/*

install: $(SYMLINKS) $(MODULES)

$(SYMLINKS):
	test -e "$(CURDIR)/$@" && ln $(LN_FLAGS) "$(CURDIR)/$@" ~/"$@"

$(MODULES):
	test -e "$(CURDIR)/$@" && mkdir -p ~/"$@"
	find "$(CURDIR)/$@" -mindepth 1 -maxdepth 1 -exec ln $(LN_FLAGS) {} ~/"$@" \;

vim-extras:
	mkdir -p ~/.vim/bundle
	test -d ~/.vim/bundle/vundle || \
	(git clone --quiet https://github.com/gmarik/vundle.git \
	~/.vim/bundle/vundle && \
	vim +BundleInstall +qall > /dev/null)

zsh-extras: z prezto

z:
	test -d ~/.zcmd || \
	git clone --quiet https://github.com/rupa/z.git ~/.zcmd

prezto:
	test -d ~/.zprezto || \
	git clone --quiet --recursive \
	https://github.com/sorin-ionescu/prezto.git ~/.zprezto

# Maintenance

check-dead:
	find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -print

clean-dead:
	find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -delete

update:
	git pull --rebase

rehash:
	test -n "$(TMUX)" && tmux source ~/.tmux.conf
	test -n "$(TMUX)" && ./tmux-rehash-panes.sh

# Packages

packages:
	test -n "$(ST_PATH)" || \
	(echo "INSTALL_PACKAGES is undefined. No idea how to install packages." \
	&& exit 1)
	$(INSTALL_PACKAGES) $(PACKAGES)

subl: $(ST_FILES)

$(ST_FILES):
	test -n "$(ST_PATH)" || \
	(echo "ST_PATH is undefined. No idea where to put symlinks" && exit 1)
	ln $(LN_FLAGS) "$(CURDIR)/dot.sublime-text/$@" "$(ST_PATH)/$@"
