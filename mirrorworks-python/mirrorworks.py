#!/usr/bin/env python3

# TODO note in README which settings in conf are optional
# TODO how to handle spaces and parens in local, remote

import json
import argparse
from os.path import expanduser
from subprocess import call

PROG = 'mirrorworks'
VERSION = '0.0.1'
CONF_AT = expanduser('~') + '/.mirrorworks/conf.json'
MODES = ['hard', 'soft', 'ignore']
DEFAULT_MODE = 'soft'
DEFAULT_OPTS = [
    '--itemize-changes', '--recursive', '--times', '--update', '--perms',
    '--executability', '--links',
    '--backup', '--backup-dir=$HOME/.mirrorworks/backup',
    '--suffix=.$(date +%Y-%m-%d-%H-%M)'
    ]

# Parse cli args and return the Namespace object.
def parse_args():
  parser = argparse.ArgumentParser(
      prog=PROG,
      usage='%(prog)s [options] <command> [bindings...]',
      description='File synchronizing tool based on rsync',
      formatter_class=argparse.RawDescriptionHelpFormatter,
      epilog='See the README for more info.')
  parser.add_argument('-v', '--version',
      action='version', version=VERSION)
  parser.add_argument('-V', '--verbose',
      help='show rsync command when executing',
      action='store_true')
  parser.add_argument('-x', '--hard',
      help='delete any extra files on transfer',
      action='store_true')
  parser.add_argument('command',
      # didn't use choices= here because it fucks up the help message
      #choices=['push', 'pull', 'list', 'status'],
      help='one of: push, pull, list, or status')
  parser.add_argument('bindings', nargs='*',
      help='if none are given, all will be used')
  return parser.parse_args()


# Validate and set defaults (if needed) on the given conf and return it.
def sanitize(conf):
  if 'rsync_opts' not in conf:
    conf['rsync_opts'] = DEFAULT_OPTS
  elif type(conf['rsync_opts']) is not list:
    raise ValueError('rsync_opts must be an array.')
  for o in conf['rsync_opts']:
    if type(o) is not str:
      raise ValueError('rsync_opts should only contain strings.')

  if 'bindings' not in conf:
    raise ValueError('No bindings defined.')
  bindings = conf['bindings']
  if type(bindings) is not dict:
    raise ValueError('bindings is not an object.')
  if len(bindings) == 0:
    raise ValueError('No bindings defined.')
  for b in bindings:
    if type(bindings[b]) is not dict:
      raise ValueError("binding '{0}' is not an object.".format(b))
    if 'local' not in bindings[b] or type(bindings[b]['local']) is not str:
      raise ValueError("Invalid or undefined 'local' in '{0}'.".format(b))
    if 'remote' not in bindings[b] or type(bindings[b]['remote']) is not str:
      raise ValueError("Invalid or undefined 'remote' in '{0}'.".format(b))
    # check modes
    if 'pushmode' not in bindings[b]:
      bindings[b]['pushmode'] = DEFAULT_MODE
    elif bindings[b]['pushmode'] not in MODES:
      raise ValueError("pushmode must be one of {0}".format(MODES))
    if 'pullmode' not in bindings[b]:
      bindings[b]['pullmode'] = DEFAULT_MODE
    elif bindings[b]['pullmode'] not in MODES:
      raise ValueError("pullmode must be one of {0}".format(MODES))
  return conf


# Returns the subset of bindings (a dict) whose names are in the names array.
# If names is empty, return all the bindings.
def get_selected_bindings(bindings, names):
  # if none were specified, return them all
  if len(names) == 0:
    return bindings
  else:
    result = {}
    for name in names:
      if name in bindings:
        result[name] = bindings[name]
      else:
        raise ValueError("No binding '{0}' defined.".format(name))
    return result


def transfer(src, dest, opts, verbose):
  # convert opts to set to drop any redundant options
  cmd = ['rsync'] + list(set(opts)) + [src, dest]
  cmdstr = ' '.join(cmd)
  if verbose:
    print('Executing: {0}'.format(cmdstr))
  # use shell=True so that variables like $HOME and ~ will be expanded
  result = call(cmdstr, shell=True)
  if result != 0:
    raise OSError('rsync exited with status {0}'.format(result))


def push(bindings, opts, verbose):
  for b in bindings:
    if bindings[b]['pushmode'] == 'ignore':
      print('---- Ignoring push for {0} ----'.format(b))
    else:
      print('>>>> Pushing {0} >>>>'.format(b))
      transfer(
          bindings[b]['local'],
          bindings[b]['remote'],
          opts + ['--delete'] if bindings[b]['pushmode'] == 'hard' else opts,
          verbose)


def pull(bindings, opts, verbose):
  for b in bindings:
    if bindings[b]['pullmode'] == 'ignore':
      print('---- Ignoring pull for {0} ----'.format(b))
    else:
      print('<<<< Pulling {0} <<<<'.format(b))
      transfer(
          bindings[b]['remote'],
          bindings[b]['local'],
          opts + ['--delete'] if bindings[b]['pullmode'] == 'hard' else opts,
          verbose)


def ls(bindings):
  print(json.dumps(bindings, indent=2, sort_keys=True))


def status(bindings, opts, verbose):
  print('Starting dry run. No changes will be made.\n')
  opts.append('--dry-run')
  push(bindings, opts, verbose)
  pull(bindings, opts, verbose)
  print('End of dry run')


try:
  args = parse_args()
  conf = sanitize(json.load(open(CONF_AT)))
  bindings = get_selected_bindings(conf['bindings'], args.bindings)
  opts = conf['rsync_opts']
  if args.hard:
    opts.append('--delete')
  if args.command == 'push':
    push(bindings, opts, args.verbose)
  elif args.command == 'pull':
    pull(bindings, opts, args.verbose)
  elif args.command == 'status':
    status(bindings, opts, args.verbose)
  elif args.command == 'list':
    ls(bindings)
  else:
    print("No command '{0}'.".format(args.command))
    exit(1)
except IOError as e:
  print(e)
  exit(1)
except ValueError as e:
  print('Exception while reading {0}:'.format(CONF_AT))
  print(e)
  exit(1)
except OSError as e:
  print(e)
  exit(1)
# TODO catch keyboard interrupt?
