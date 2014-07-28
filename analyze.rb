require_relative "model.rb"

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
f = ARGF.read.scrub.split
f.each do |line|
  word = line.chomp.downcase
  next unless word =~ /^[a-z]+$/
  strokes = type_word(word)

  count += 1
  sum += strokes.length
  sc += word.length/strokes.length.to_f
  len += word.length

  # if rand() < 0.0003 && word =~ /^[a-z]+$/
  #   puts "#{word}: #{strokes.count}"
  #   p strokes
  #   p strokes.map(&:keys_down)
  # end
end
puts "Total words: #{count}"
puts "Average word length: #{len/count.to_f}"
puts "Average strokes/word: #{sum/count.to_f}"
puts "Average characters per stroke: #{sc/count.to_f}"
puts "Total strokes: #{sum}"
