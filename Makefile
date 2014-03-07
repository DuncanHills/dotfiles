# -----------------------------------------------------------------------------
# Setup
#

IGNORE_FILE = ignores
PACKAGES_FILE = packages
MODULES_FILE = modules

SHELL = /bin/bash
CURDIR ?= $(.CURDIR)
LN_FLAGS = -sfn
COLOR = \033[32;01m
NO_COLOR = \033[0m

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
.PHONY: all install clean check-dead clean-dead update $(SYMLINKS) $(MODULES)

# -----------------------------------------------------------------------------
# Help
#

help:
	@echo "Makefile for installing dotfiles"
	@echo
	@echo "Create symlinks:"
	@echo " $(COLOR)make install$(NO_COLOR)    Install symlinks"
	@echo
	@echo "Install vim and shell extras:"
	@echo " $(COLOR)make vim-extras$(NO_COLOR) Install vim bundles"
	@echo " $(COLOR)make zsh-extras$(NO_COLOR) Install prezto and z"
	@echo " $(COLOR)make prezto$(NO_COLOR)     Install prezto"
	@echo " $(COLOR)make z$(NO_COLOR)          Install z"
	@echo
	@echo "Install common packages:"
	@echo " $(COLOR)make packages$(NO_COLOR)   Install default packages"
	@echo
	@echo "Install Sublime Text config:"
	@echo " $(COLOR)make subl$(NO_COLOR)       Install Sublime Text config"
	@echo
	@echo "Maintenance:"
	@echo " $(COLOR)make clean$(NO_COLOR)      Delete vim bundles"
	@echo " $(COLOR)make check-dead$(NO_COLOR) Print dead symlinks"
	@echo " $(COLOR)make clean-dead$(NO_COLOR) Delete dead symlinks"
	@echo " $(COLOR)make update$(NO_COLOR)     Alias for git pull --rebase"
	@echo " $(COLOR)make rehash$(NO_COLOR)     Source .zshrc in all tmux \
	panes"
	@echo
	@echo "Useful aliases:"
	@echo " $(COLOR)make all$(NO_COLOR) install vim-extras zsh-extras"

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
	find "$(CURDIR)/$@" -mindepth 1 -maxdepth 1 -type f -exec ln $(LN_FLAGS) {} ~/"$@" \;

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
