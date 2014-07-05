# Model of VeloType typing
require "state_machine"

class StrokeModel
  LAYOUT = %w{zfs ptc kjr ioeua lny}
  attr_accessor :parts
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
    @pressed = {}
    @state = :start

    @parts = [""]
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
    @parts.last << c
    return :good
  rescue CanNotStrokeError => e
    return :notsyllable
  end
end

def type_word(word)
  stroke = StrokeModel.new
  count = 1
  word.each_char do |c|
    result = stroke.add(c)
    unless result == :good
      count += 1
      p stroke.parts
      stroke.reset
      stroke.add(c) # we need to actually use the failed letter
    end
  end
  p stroke.parts
  count
end

File.foreach(ARGV[0] || "/usr/share/dict/words") do |line|
  word = line.chomp.downcase
  if rand() < 0.0003 && word =~ /^[a-z]+$/
    count = type_word(word)
    puts "#{word}: #{count}"
  end
end
