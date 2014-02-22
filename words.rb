#!/usr/bin/env ruby

# prints possible solutions to the 4 Pics 1 Word game
# call like `ruby words.rb <available letters> <number of letters>`

dictFile = "/usr/share/dict/cracklib-small"

$dictionary = []
$solutions = []  # so we don't show repeated possible solutions

start_time = Time.now
$letters = ARGV[0].split ""
$size = ARGV[1].to_i

# put dict into array
File.open(dictFile).each do |word|
    word = word.chomp
    keep = true
    # exclude word if it contains a letter not available
    word.each_char { |c| keep = false unless $letters.include? c }
    # exlude word if it doesn't match the size
    keep = false unless word.size == $size

    if keep then $dictionary << word end
end

# both args are arrays of letters
def recur(current, remaining)
    if current.size == $size
        word = current.join
        if $dictionary.include? word and not $solutions.include? word
            $solutions << word
            puts word
        end
    elsif current.size < $size
        remaining.each do |r|
            new_cur = Array.new current
            new_remaining = Array.new remaining
            new_remaining.delete_at new_remaining.index(r)
            new_cur << r
            recur(new_cur, new_remaining)
        end
    end
end

puts "#{$letters.size} letters given"

recur([], $letters)

puts "#{$solutions.size} solutions"
end_time = Time.now
puts "Time (sec): #{end_time - start_time}"
