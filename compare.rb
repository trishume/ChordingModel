require_relative "model.rb"

require "json"
dict = JSON.parse(IO.read("steno_dicts/dict_unsorted.json"))
list = IO.read("mword10/freq.txt").lines.map(&:chomp).map(&:downcase)

idict = {}
counts = {}
dict.each do |k,v|
  next unless v =~ /^[a-z]+$/
  len = k.count('/')
  next if idict[v] && idict[v].count('/') < len
  idict[v] = k
  counts[v] = len+1
end

list.each do |word|
  next unless word =~ /^[a-z]+$/
  steno_count = counts[word]
  next unless steno_count
  strokes = type_word(word)
  velo_count = strokes.length
  if steno_count < velo_count
    puts "#{word}: velo=#{velo_count}=#{strokes.inspect} steno=#{steno_count}=#{idict[word]}"
  end
end
