require_relative "model"
require "trie"
require "pry"

LAYOUT_FILE2 = 'layout_highbar.txt'
LAYOUT_FINGERS2 = 26
PERFECT_LAYOUT = load_layout(LAYOUT_FILE2)

TRIE = Trie.new
words = []
IO.foreach("mword10/count_words.txt") do |l|
  word, count = l.split
  # p [l, l.split, word, count]
  TRIE.add word, count.to_i
  words << word
end

def type_word_lay(word, layout, fingers)
  all = []
  i = 0
  loop do
    stroke = StrokeModel.new(layout, fingers)
    i += stroke.add_word(word[i..-1])
    all << stroke
    if i == word.length
      return all
    end
  end
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
stat = [0,0,0,0,0]
words.each_with_index do |word,i|
  strokes = type_word_lay(word, LAYOUT, LAYOUT_FINGERS)
  strokes2 = type_word_lay(word, PERFECT_LAYOUT, LAYOUT_FINGERS2)
  len = strokes.length

  fail = strokes.length > strokes2.length
  add_stats(stat, [1, len, word.length/len.to_f, word.length, fail ? 1 : 0], TRIE.get(word))

  if fail && i < 500
    puts "#{word}: #{len}"
    p strokes
    p strokes2
    # p strokes.map(&:keys_down)
  end
end
puts "Total words: #{words.length}"
count = stat.first.to_f
stat.map! {|s| s / count}
puts "Average word length: #{stat[3]}"
puts "Average strokes/word: #{stat[1]}"
puts "Average characters per stroke: #{stat[2]}"
puts "Failure fraction: #{stat[4]}"
