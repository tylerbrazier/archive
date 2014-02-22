#!/usr/bin/env ruby

require 'io/console'

# use print instead of puts if you don't want newline
$stdout.sync = true  # always flush output on print
$state = "locked"

def prompt(message, prompt_text="Secret Stash (#{$state}) ")
    puts message
    print prompt_text
    return gets.chomp
end

puts "First arg should be path to file"

print "Unlock with password: "
unlock_password = STDIN.noecho(&:gets).chomp # don't show what user is typing

