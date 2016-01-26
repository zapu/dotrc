#!/usr/bin/env python3

import os
import os.path as path
import platform

assert platform.system() == 'Linux', "This install script is Linux only."

#import deps.sh as sh
import deps.blessings as blessings

term = blessings.Terminal()

home_dir = path.realpath(path.expanduser("~"))
config_dir = path.dirname(path.realpath(__file__))
assert path.isdir(home_dir), "Home dir?"

def assert_install_to(our_name, target_name, is_dir=False):
    """
    Check if we shall install a config file to filename. We are not
    installing if the filename is taken (if there is a directory with
    this name or other file) or target is already a symbolic link to
    our file.

    We are also not installing if directory that would contain target
    name does not exist.

    Return a tuple of (can_install, reason). Reason can be None when
    there is no error, and when there is, it is interpreted as "can't
    install, already installed".
    """
    if not is_dir:
        assert path.isfile(our_name), "{} exists?".format(our_name)
    else:
        assert path.isdir(our_name), "{} exists?".format(our_name)

    assert not path.islink(our_name), "{} is not a link?".format(our_name)

    if path.islink(target_name):
        if path.realpath(target_name) == path.realpath(our_name):
            return (False, None)
        else:
            return (False, "There is a file (symbolic link) in the target path.")
    elif not is_dir and path.isdir(target_name):
        return (False, "Target path is a directory")
    elif is_dir and path.isfile(target_name):
        return (False, "Target path is a file")
    elif path.exists(target_name):
        return (False, "Target name already exists.")
    elif not path.isdir(path.dirname(path.realpath(target_name))):
        return (False, "Target path's parent dir does not exist.")
    else:
        return (True, "")

def try_install_interactive(name, our, target, is_dir=False):
    """
    Checks if it is possible to install. Makes symlink and prints
    message to terminal.
    """
    can_install, why = assert_install_to(our, target, is_dir)

    if not can_install:
        if not why:
            print(term.magenta('❤'), '{} is already installed.'.format(term.yellow(name)))
        else:
            print(term.red('✗'), 'Not installing {}: {}'.format(term.yellow(name), why))
    else:
        os.symlink(our, target)
        print(term.green('✓'), 'Installing {}'.format(term.yellow(name)))

for file in ['.tmux.conf', '.zshrc', '.gitconfig', '.zshenv', '.vimrc']:
    our = path.join(config_dir, file)
    target = path.join(home_dir, file)
    if file == '.gitconfig' and os.getlogin() != 'zapu':
        print(term.red('x'),
            "Not installing {}, or are you really me?".format(term.yellow(file)))
        continue

    try_install_interactive(file, our, target)


# Install sublime-text-3 packages dir

def install_sublime():
    our = path.join(config_dir, 'sublime-text-3')
    target = path.join(home_dir, '.config', 'sublime-text-3', 'Packages')

    try_install_interactive('sublime-text-3/Packages', our, target, is_dir=True)

install_sublime()

# Install .vim folder

def install_dotvim():
    our = path.join(config_dir, '.vim')
    target = path.join(home_dir, 'vim')

    try_install_interactive('.vim', our, target, is_dir=True)

install_dotvim()
