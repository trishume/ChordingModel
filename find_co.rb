require "pry"
class Syllable
  attr_accessor :start,:middle,:ending
  def initialize(*args)
    @start,@middle,@ending = *args
  end
  def to_a
    [start,middle,ending]
  end
  def inspect
    "<#{start}+#{middle}+#{ending}>"
  end
end

CONSONANTS = /^[^aoeui]+/
VOWELS = /^[aoeui]+/
def syllables(word)
  return [] if word.length == 0
  # starting consonants
  start = word[CONSONANTS] || ''
  # middle vowels
  middle = word[start.length..-1][VOWELS] || ''
  # ending consonants
  rest = word[(middle.length+start.length)..-1] || ''
  last = rest[CONSONANTS] || ''
  return [Syllable.new(start,middle,last)] + syllables(rest[last.length..-1])
end

def has_both?(str, a, b)
  str.include?(a) && str.include?(b)
end

query = ARGV[1]
a,b = query.chars
all = []
File.foreach(ARGV[0]) do |line|
  word = line.chomp.downcase
  next unless word =~ /^[a-z]+$/

  s = syllables(word)
  s.each do |syl|
    if has_both?(syl.start, a, b) || has_both?(syl.ending, a, b)
      all << word
    end
  end
end

RESULTS = 20
puts "Count: #{all.length}"
puts all.sample(20)
