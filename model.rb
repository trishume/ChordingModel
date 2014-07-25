# Model of VeloType typing
require "state_machine"

def load_layout
  map = {}
  File.foreach("layout.txt") do |line|
    next if line.strip.empty? || line[0] == '#'
    parts = line.chomp.split
    map[parts[0]] = parts[1..-1].map {|k| k[0].to_i}
  end
  map
end

LAYOUT = load_layout

class StrokeModel
  attr_accessor :parts, :pressed
  class CanNotStrokeError < StandardError; end

  state_machine :state, :initial => :begin do
    event :vowel do
      transition :start => :middle, :final => :fail, :middle => same,
        :special => :fail, :begin => :middle
    end
    event :consonant do
      transition :start => same, :middle => :final, :final => same, :special => :fail,
        :special => :fail, :begin => :start
    end
    event :ending_e do
      transition :final => :special
    end
    event :special do
      transition :begin => :special
      transition any => :fail
    end
    event :reset do
      transition all => :begin
    end

    after_transition any => :fail do |state,transition|
      raise CanNotStrokeError, "Can't transition from #{state} with #{transition}"
    end
    after_transition :start => :middle, :middle => :final do |stroke|
      stroke.parts << ""
    end
    after_transition any => :begin do |stroke|
      stroke.parts = [""]
    end

    state :begin
    state :start
    state :middle
    state :final
    state :special
    state :fail
  end

  def initialize
    # 2 hands with 5 fingers + palm
    @pressed = Array.new(2) { Array.new(6,false) }
    @state = :start

    @parts = [""]
  end

  def press(layer, finger)
    return false if @pressed[layer][finger]
    @pressed[layer][finger] = true
    true
  end

  def alloc_vowel(c)
    finger = LAYOUT[c][0]
    if !press(0, finger)
      return press(1, finger)
    end
    true
  end

  def alloc_finger(c)
    return alloc_vowel(c) if self.middle?
    fingers = LAYOUT[c]
    layer = (self.final?) ? 1 : 0
    return fingers.all? {|finger| press(layer,finger)}
  end

  def add(c)
    c = '&' if c=='e' && self.final?
    case c
    when /[bcdfghjklmnpqrstvwxyz]/i
      self.consonant
    when /[aoeui]/i
      self.vowel
    when '&'
      self.ending_e
    else
      self.special
    end
    can_press = alloc_finger(c)
    return :nofinger unless can_press
    @parts.last << c
    return :good
  rescue CanNotStrokeError => e
    return :notsyllable
  end

  def inspect
    @parts.join('')
  end

  def keys_down
    @pressed.map do |hand|
      hand.map.with_index {|pr, i| pr ? i : nil}.compact
    end
  end
end

def type_word(word)
  all = []
  stroke = StrokeModel.new
  word.each_char do |c|
    result = stroke.add(c)
    unless result == :good
      all << stroke
      stroke = StrokeModel.new
      stroke.add(c) # we need to actually use the failed letter
    end
  end
  all << stroke
  all
end

if (w = ARGV[1])
  strokes = type_word(w)
  p strokes
  p strokes.map {|s| s.keys_down }
  exit
end

sum = 0
count = 0
sc = 0
len = 0
f = ARGF.read.split
f.each do |line|
  word = line.chomp.downcase
  strokes = type_word(word)
  next unless word =~ /^[a-z]+$/

  count += 1
  sum += strokes.length
  sc += word.length/strokes.length.to_f
  len += word.length

  if rand() < 0.0003 && word =~ /^[a-z]+$/
    puts "#{word}: #{strokes.count}"
    p strokes
    p strokes.map(&:keys_down)
  end
end
puts "Total words: #{count}"
puts "Average word length: #{len/count.to_f}"
puts "Average strokes/word: #{sum/count.to_f}"
puts "Average characters per stroke: #{sc/count.to_f}"
puts "Total strokes: #{sum}"
