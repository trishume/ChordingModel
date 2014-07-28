require "json"
counts = JSON.parse(IO.read("steno_dicts/stroke_counts.json"))

sum = 0
count = 0
sc = 0
len = 0
fails = 0
new_dict = {}
f = ARGF.read.scrub.split
f.each do |line|
  word = line.chomp.downcase
  next unless word =~ /^[a-z]+$/
  strokes = counts[word]
  unless strokes
    strokes = 2
    fails += 1 unless new_dict[word]
    new_dict[word] = true
  end

  count += 1
  sum += strokes
  sc += word.length/strokes.to_f
  len += word.length
end
puts "Total words: #{count}"
puts "Average word length: #{len/count.to_f}"
puts "Average strokes/word: #{sum/count.to_f}"
puts "Average characters per stroke: #{sc/count.to_f}"
puts "Total strokes: #{sum}"
puts "Dictionary failures: #{fails}"
puts "Sampled failures:"
p new_dict.to_a.sample(20).map {|a| a.first}
