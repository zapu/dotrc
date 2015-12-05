#!/usr/bin/env python3

import os
import os.path as path

#import deps.sh as sh
import deps.blessings as blessings

term = blessings.Terminal()

home_dir = path.realpath(path.expanduser("~"))
config_dir = path.dirname(path.realpath(__file__))
assert path.isdir(home_dir), "Home dir?"

def assert_install_to(our_name, target_name):
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
    assert path.isfile(our_name), "{} exists?".format(our_name)
    assert not path.islink(our_name), "{} is not a link?".format(our_name)

    if path.islink(target_name):
        if path.realpath(target_name) == path.realpath(our_name):
            return (False, None)
        else:
            return (False, "There is a file (symbolic link) in the target path.")
    elif path.isfile(target_name):
        return (False, "File on target name already exists.")
    elif path.isdir(target_name):
        return (False, "Target path is a directory")
    elif not path.isdir(path.dirname(path.realpath(target_name))):
        return (False, "Target path's parent dir does not exist.")
    else:
        return (True, "")

for file in ['.tmux.conf', '.zshrc', '.gitconfig', '.zshenv', '.vimrc']:
    our = path.join(config_dir, file)
    target = path.join(home_dir, file)
    if file == '.gitconfig' and os.getlogin() != 'zapu':
        print(term.red('x'), 
            "Not installing {}, or are you really me?".format(term.yellow(file)))
        continue

    can_install, why = assert_install_to(our, target)

    if not can_install:
        if not why:
            print(term.magenta('❤'), '{} is already installed.'.format(term.yellow(file)))
        else:
            print(term.red('✗'), 'Not installing {}: {}'.format(term.yellow(file), why))
    else:
        os.symlink(our, target)
        print(term.green('✓'), 'Installing {}'.format(term.yellow(file)))
        
