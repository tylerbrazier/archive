Gem::Specification.new do |s|
    s.name        = "mirrorworks"
    s.version     = "0.0.0"
    s.date        = "2013-12-25"
    s.summary     = "A simple directory synchronizing script"
    s.description = "An rsync wrapper script for synchronizing directories"
    s.authors     = ["Tyler Brazier"]
    s.email       = "tylerbrazier@gmail.com"
    s.homepage    = "http://github.com/tylerbrazier/mirrorworks"
    s.license     = "MIT"
    s.executables = ["mirrorworks"]
    s.files       = ["lib/mirrorworks.rb",
                     "lib/mirrorworks/arg_handler.rb"]
end
