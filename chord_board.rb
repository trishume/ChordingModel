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

class Analyzer
  THRESH = 0.0001
  attr_accessor :pairs
  def initialize(name, options = {})
    @options = {filter:/.*/,dofreqs:true}
    @options.merge!(options)
    @name = name
    @pairs = Hash.new
    ('a'..'z').each do |first|
      next unless first =~ @options[:filter]
      (first..'z').each do |second|
        next unless second =~ @options[:filter]
        pair = first + second
        @pairs[pair] = 0
      end
    end
    @freqs = Hash.new(0)
    @total = 0
  end
  def add(str)
    @total += 1
    @freqs[str] += 1 if @options[:dofreqs]
    str.each_char.with_index do |c1, i|
      ((i+1)..(str.length-1)).each do |i2|
       p = [str[i2],c1].sort.join('')
       next unless @pairs[p]
       @pairs[p] += 1
      end
    end
  end
  def zeros
    max_freq = THRESH * @total
    zeros = []
    @pairs.each do |key,val|
      next unless val && val < max_freq
      zeros << key
    end
    zeros
  end
  def report
    puts "# Analyzer report for: #{@name} =========="
    puts "Total possibilities: #{@freqs.size}" if @options[:dofreqs]
    zer = zeros
    puts "Zeros: #{zer.size}/#{@pairs.size} = #{zer.size / pairs.size.to_f}"
    p zer
  end
end

def is_vowel?(char)
  %w(a o e u i).include?(char)
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

#binding.pry
analyzers = {
  word: Analyzer.new("Words",dofreqs:false),
  start: Analyzer.new("start",filter:CONSONANTS),
  vowels: Analyzer.new("vowels",filter:VOWELS),
  endings: Analyzer.new("end",filter:CONSONANTS),
  consonants: Analyzer.new("consonants",filter:CONSONANTS),
}
File.foreach(ARGV[0] || "/usr/share/dict/words") do |line|
  word = line.chomp.downcase
  analyzers[:word].add(word)
  s = syllables(word)
  s.each do |syllable|
    analyzers[:start].add(syllable.start)
    analyzers[:vowels].add(syllable.middle)
    analyzers[:endings].add(syllable.ending)

    analyzers[:consonants].add(syllable.start)
    analyzers[:consonants].add(syllable.ending)
  end
end
puts "========== REPORT - THRESH=#{Analyzer::THRESH} - INPUT=#{ARGV[0]} ==========="
analyzers.each { |name,a| a.report}
