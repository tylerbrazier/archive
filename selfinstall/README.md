Self Installer
==============

Create a self-extracting archive script.

Put the files you want into the payload directory and they will be embedded into
the install script. When the script is run, the embedded payload will be
extracted into the cwd.

You can include a 'preinstall' and/or 'postinstall' in the same directory as
create-installer.sh. These can include any logic you want to happen before and
after the payload is extracted. Their contents will be included in the
installer. You can safely include `rm $0` in 'postinstall' to delete the
installer if you want:
http://stackoverflow.com/questions/7834667/self-deleting-bash-script.
