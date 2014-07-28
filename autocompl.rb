require_relative "model"
require "trie"
require "pry"

N = 492572133121

TRIE = Trie.new
words = []
IO.foreach("mword10/count_words.txt") do |l|
  word, count = l.split
  # p [l, l.split, word, count]
  TRIE.add word, count.to_i
  words << word
end

def complete(prefix)
  children = TRIE.children(prefix)
  children.max_by {|w| TRIE.get(w)}
end

def complete_top(prefix, top = 0)
  children = TRIE.children(prefix)
  sorted = children.sort {|x,y| TRIE.get(y) <=> TRIE.get(x)}
  sorted[0..top]
end

def complete_word(word)
  all = []
  i = 0
  loop do
    stroke = StrokeModel.new
    i += stroke.add_word(word[i..-1])
    all << stroke
    completed = complete_top(word[0..i])
    return all if completed.include?(word)
    if i == word.length
      all << :!
      return all
    end
  end
end

if word = ARGV[0]
  first_stroke = StrokeModel.new
  first_stroke.add_word(word)
  puts "First stroke: #{first_stroke.inspect}"
  puts "Completed first stroke: #{complete(first_stroke.inspect)}"
  puts "Typed strokes: #{complete_word(word)}"
  puts "Possible words:"
  p TRIE.children(first_stroke.inspect)
  exit
end

def add_stats(old, nums, weight)
  nums.each_with_index do |n, i|
    old[i] += n*weight
  end
end

sum = 0
count = 0
sc = 0
len = 0
stat = [0,0,0,0]
words.each do |word|
  strokes = complete_word(word)
  len = strokes.length

  add_stats(stat, [1, len, word.length/len.to_f, word.length], TRIE.get(word))

  if rand() < 0.0003
    puts "#{word}: #{len}"
    p strokes
    # p strokes.map(&:keys_down)
  end
end
puts "Total words: #{words.length}"
count = stat.first.to_f
stat.map! {|s| s / count}
puts "Average word length: #{stat[3]}"
puts "Average strokes/word: #{stat[1]}"
puts "Average characters per stroke: #{stat[2]}"
