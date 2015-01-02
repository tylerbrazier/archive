require './lib/mirrorworks.rb'

Gem::Specification.new do |s|
  s.name        = 'mirrorworks'
  s.version     = Mirrorworks::VERSION
  s.license     = 'MIT'
  s.summary     = 'A handy rsync wrapper cli tool'
  s.description = 'A file and directory synchronizer tool that wraps rsync'
  s.author      = 'Tyler Brazier'
  s.email       = 'tyler@tylerbrazier.com'
  s.homepage    = 'http://github.com/tylerbrazier/mirrorworks'
  s.executables = ['mirrorworks']
  s.files       = ['README.md',
                   'LICENSE',
                   'example.mirrorworksrc.json',
                   'lib/mirrorworks.rb']
  s.add_dependency 'rsync', '~> 1.0'
end
