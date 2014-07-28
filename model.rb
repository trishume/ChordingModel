# Model of VeloType typing
require "state_machine"
require "strscan"

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
SUFFIXES = /(er|ed|en|e|ion|able|ing|al)/
# SUFFIXES = /(e)/

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
    event :suffix do
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
    after_transition :start => :middle, :middle => :final, :final => :special do |stroke|
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
    case c
    when /[bcdfghjklmnpqrstvwxyz]/i
      self.consonant
    when /[aoeui]/i
      self.vowel
    else
      self.special
    end
    # can_press = alloc_finger(c)
    # return :nofinger unless can_press
    @parts.last << c
    return :good
  rescue CanNotStrokeError => e
    return :notsyllable
  end

  def add_word(str)
    sc = StringScanner.new(str)
    loop do
      case
      when self.final? && sc.scan(SUFFIXES)
        self.suffix
        @parts.last << sc[1]
      when (c = sc.getch)
        res = add(c)
        return sc.pos - 1 unless res == :good
      else
        return sc.pos
      end
    end
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
  i = 0
  loop do
    stroke = StrokeModel.new
    i += stroke.add_word(word[i..-1])
    all << stroke
    if i == word.length
      return all
    end
  end
end
