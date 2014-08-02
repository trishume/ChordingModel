require "pry"
require "yaml"
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
THRESH = 0.0005
class Analyzer
  attr_accessor :pairs, :total, :letterfreqs
  def initialize(name, options = {})
    @options = {filter:/.*/,dofreqs:true, letterfreqs: false}
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
    @letterfreqs = Hash.new(0)
    @lettertotal = 0
    @total = 0
  end
  def add(str, weight = 1)
    @total += weight
    @freqs[str] += 1 if @options[:dofreqs]
    str.each_char.with_index do |c1, i|
      ((i+1)..(str.length-1)).each do |i2|
       p = [str[i2],c1].sort.join('')
       next unless @pairs[p]
       @pairs[p] += weight
      end
    end

    if @options[:letterfreqs]
      @lettertotal += weight * str.length
      str.each_char do |c|
        @letterfreqs[c] += weight
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
    if @options[:letterfreqs]
      @letterfreqs.each {|k,v| @letterfreqs[k] = v / @lettertotal.to_f}
      puts "Letter frequencies:"
      p @letterfreqs
      total = @letterfreqs.to_a.map { |e| e[1] }.inject(:+)
      puts "Total: #{total}"
    end
    # zer = zeros
    # puts "Zeros: #{zer.size}/#{@pairs.size} = #{zer.size / pairs.size.to_f}"
    # p zer
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
    @indexh = @letters.map.with_index {|l,i| [l,i]}.to_h

    @matrix = to_matrix(@analyzer.pairs, @analyzer.total)
    @triangles = gen_triangles
  end

  def to_matrix(pairs, total)
    matrix = Array.new(@letters.length) { Array.new(@letters.length, 0) }
    pairs.each do |pr, count|
      a = @indexh[pr[0]]
      b = @indexh[pr[1]]
      freq = count / total.to_f
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
        v = (v == 0) ? 0 : (-Math.log10(v)).round(2)
        s = v.to_s.ljust(width)
        print s
      end
      puts
    end
  end

  def matrix_hash
    h = {}
    matrix.each_with_index do |row, i|
      h2 = {}
      row.each_with_index do |p, j|
        h2[@letters[j]] = p
      end
      h[@letters[i]] = h2
    end
    h
  end

  def letter_report
    res = @letters.map do |c|
      sum = @matrix[@indexh[c]].inject(:+)
      [c,sum]
    end
    res.sort_by! {|a| a.last}
    res.each {|a| puts "#{a[0]} = #{a[1]}"}
  end

  def look(a,b)
    @matrix[@indexh[a]][@indexh[b]]
  end

  def gen_triangles
    triangles = []
    @letters.combination(3).each do |tri|
      score = look(tri[0],tri[1]) + look(tri[1],tri[2]) + look(tri[0],tri[2])
      triangles << [tri.sort.join(''),score]
    end
    triangles.sort_by! {|a| a.last}
  end

  def interactive_lookup
    tri_hash = @triangles.to_h
    loop do
      print ">> "
      q = gets.chomp
      break if q == "exit"

    end
  end

  def velo_report
    tri_hash = @triangles.to_h
    ['cpt','jkr','fsz','lny'].each do |q|
      puts "#{q} = #{tri_hash[q]} one in #{1.0/tri_hash[q]}"
    end
  end

  def print_top_triangles
    good = @triangles.select {|tri| tri[1]<0.004}
    puts "["
    good.each {|a| puts "#{a.inspect},"}
    puts ']'
  end
end

#binding.pry
analyzers = {
  word: Analyzer.new("Words",dofreqs:false, letterfreqs: true),
  start: Analyzer.new("start",filter:CONSONANTS,letterfreqs: true),
  vowels: Analyzer.new("vowels",filter:VOWELS),
  endings: Analyzer.new("end",filter:CONSONANTS,letterfreqs: true),
  consonants: Analyzer.new("consonants",filter:CONSONANTS),
}
count = 0
set = Hash.new(0)
File.foreach("mword10/count_words.txt") do |line|
  word,weight = line.chomp.downcase.split
  weight = weight.to_i
  count += 1
  analyzers[:word].add(word, weight)
  s = syllables(word)
  s.each do |syllable|
    set[syllable.inspect] += 1
    analyzers[:start].add(syllable.start, weight)
    analyzers[:vowels].add(syllable.middle, weight)
    analyzers[:endings].add(syllable.ending, weight)

    analyzers[:consonants].add(syllable.start, weight)
    analyzers[:consonants].add(syllable.ending, weight)
  end
end
# set.select! {|k,v| v > THRESH*count}
puts "Words Analyzed: #{count}"
puts "Unique Syllables: #{set.count}"
p set if set.count < 200
puts "========== REPORT - THRESH=#{Analyzer::THRESH} - INPUT=#{ARGV[0]} ==========="
analyzers[:word].report
analyzers[:start].report
analyzers[:endings].report
puts "=== Word freqs"
p analyzers[:word].letterfreqs.to_a.sort_by {|a| a[1]}.reverse
puts "=== Freq difference (start - end)"
diffs = analyzers[:start].letterfreqs.to_a.map do |a|
  freq2 = analyzers[:endings].letterfreqs[a[0]]
  a + [freq2, a[1] - freq2]
end
diffs.sort_by! {|a| a[3]}
diffs.each do |a|
  puts "#{a[0]}: #{a[3]} = #{a[1]} - #{a[2]}"
end
puts "====== TRIANGLES ====="
finder = TriangleFinder.new(analyzers[:consonants], "bcdfghjklmnpqrstvwxyz")
# pp finder.matrix
finder.print_matrix
finder.letter_report
finder.velo_report
# finder.print_top_triangles
# finder.interactive_lookup
# puts finder.matrix_hash.to_yaml
