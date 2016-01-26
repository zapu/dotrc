import os
import os.path as path
import platform
import sys

assert platform.system() == 'Windows', "This install script is Windows only."

#import deps.sh as sh

import codecs
sys.stdout = codecs.getwriter('utf8')(sys.stdout.detach())

home_dir = path.realpath(path.expanduser("~"))
roaming_dir = path.realpath(os.getenv('APPDATA'))
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
            print('❤ {} is already installed.'.format(name))
        else:
            print('✗ Not installing {}: {}'.format(name, why))
    else:
        os.symlink(our, target)
        print('✓ Installing {}'.format(name))

def install_file(config_file_name, target_dir, target_file_name = None):
    if target_file_name == None:
        target_file_name = config_file_name

    our = path.join(config_dir, config_file_name)
    target = path.join(target_dir, target_file_name)
    if target_file_name == '.gitconfig' and \
        (os.getlogin() != 'zapu' and os.getlogin() != 'Zapu'):
        print("Not installing {}, or are you really me?".format(target_file_name))
        return

    try_install_interactive(config_file_name, our, target)

# Install windows config files

install_file('.vimrc', home_dir)
install_file('.gitconfig_win', home_dir, '.gitconfig')

# Install sublime-text-3 packages dir

def install_sublime():
    our = path.join(config_dir, 'sublime-text-3')
    target = path.join(roaming_dir, 'Sublime Text 3', 'Packages')

    try_install_interactive('Sublime Text 3/Packages', our, target, is_dir=True)

install_sublime()

