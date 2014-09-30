require "trie"
require "pry"

TRIE = Trie.new
words = []
$total_count = 0
IO.foreach("mword10/count_words.txt") do |l|
  word, count = l.split
  # p [l, l.split, word, count]
  TRIE.add word, count.to_i
  $total_count += count.to_i
  words << word
end

def total_frac(words)
  sub_count = words.map {|w| TRIE.get(w)}.inject(:+)
  sub_count / $total_count.to_f
end

def count_letters(words, size)
  words.count {|w| w.length == size}
end

[100,1000,2000,5000,10_000,-1].each do |n|
  a = words[0..n]
  puts "Top #{n}: #{total_frac(a)}"
  puts "3 letters in top #{n}: #{count_letters(a,3)}"
end




