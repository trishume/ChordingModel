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

class TriangleFinder
  attr_accessor :matrix
  def initialize(analyzer,letters)
    @analyzer = analyzer
    @letters = letters.chars.to_a

    @matrix = to_matrix(@analyzer.pairs)
  end

  def to_matrix(pairs)
    matrix = Array.new(@letters.length) { Array.new(@letters.length, 0) }
    pairs.each do |pr, freq|
      a = @letters.find_index(pr[0])
      b = @letters.find_index(pr[1])
      matrix[a][b] = freq
      matrix[b][a] = freq
    end
    matrix
  end

  def print_matrix
    width = 5
    print " "*width
    @letters.each {|c| print c.to_s.ljust(width)}
    puts
    @letters.length.times do |r|
      print @letters[r].ljust(width)
      @letters.length.times do |c|
        v = @matrix[r][c]
        # v = (v == 0) ? 0 : Math.log10(v).round
        s = v.to_s.ljust(width)
        print s
      end
      puts
    end
  end
end

#binding.pry
analyzers = {
  word: Analyzer.new("Words",dofreqs:false),
  start: Analyzer.new("start",filter:CONSONANTS),
  vowels: Analyzer.new("vowels",filter:VOWELS),
  endings: Analyzer.new("end",filter:CONSONANTS),
  consonants: Analyzer.new("consonants",filter:CONSONANTS),
}
count = 0
File.foreach(ARGV[0] || "/usr/share/dict/words") do |line|
  word = line.chomp.downcase
  next unless word =~ /^[a-z]+$/
  count += 1
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
puts "Words Analyzed: #{count}"
# puts "========== REPORT - THRESH=#{Analyzer::THRESH} - INPUT=#{ARGV[0]} ==========="
# analyzers.each { |name,a| a.report}
puts "====== TRIANGLES ====="
finder = TriangleFinder.new(analyzers[:consonants], "bcdfghjklmnpqrstvwxyz")
# pp finder.matrix
finder.print_matrix
