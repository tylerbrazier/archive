Mirrorworks
===========

A handy rsync wrapper cli tool.

This is a dead-simple script that lets you easily set up pairs of files or
directories (called 'reflections') and sync them locally or over the network
with commands like  
`$ mirrorworks push`  
and  
`$ mirrorworks pull`

Development Status
------------------
This is the node.js implementation. I'm planning on implementing it in ruby
also because of a couple of reasons:

* Since the calls to rsync are asynchronous, there are problems if rsync ever
prompts for anything like host verification, passwords, or passphrases. To fix
this, the script could, by default, run synchronously and provide an option
for running asynchronously. This would pretty much require a rewrite of the
whole script anyway.
* I want to provide Windows support. The problem is Windows doesn't have a
native rsync implementation so cygwin is required. The problem with this idea
is that node is not supported by cygwin since windows has a native
implementation for node. It's a big mess and getting things to work correctly
together is probably more of a hassle than it's worth.

So, since the script needs to be rewritten anyway, it seems the best option is
to re-implement it in another language that can be used in unix/linux and
cygwin. This will probably be the final version of this node implementation :(

Installation and Configuration
------------------------------
Make sure you have rsync installed on your system.

Install Mirrorworks globally with  
`# npm install mirrorworks -g`

Copy and edit the example config file to your home directory
`$ cp /usr/lib/node_modules/mirrorworks/example.mirrorworksrc.json ~/.mirrorworksrc.json`

This file contains some underlying rsync config options as well as a set of
'reflections'. Reflections are pairs files or directories that you want to have
synchronized. Each consists of a name, a local file/dir, and a remote file/dir.
There are a few things to remember when setting up your reflections:

* The name of each reflection should be unique.
* The path to directories should end in a slash /.
* You can use '$HOME' or '~' to refer to your home directory.
* The script doesn't like paths that include a space.

Using Mirrorworks
-----------------
The script is very straightforward. For usage, run  
`$ mirrorworks --help`
