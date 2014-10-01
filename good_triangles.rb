require "json"
require "yaml"
require "aggregate"

FREQS = {
'e' => 12.02,'t' => 9.10,'a' => 8.12,'o' => 7.68,'i' => 7.31,
'n' => 6.95,'s' => 6.28,'r' => 6.02,'h' => 5.92,'d' => 4.32,
'l' => 3.98,'u' => 2.88,'c' => 2.71,'m' => 2.61,'f' => 2.30,
'y' => 2.11,'w' => 2.09,'g' => 2.03,'p' => 1.82,'b' => 1.49,
'v' => 1.11,'k' => 0.69,'x' => 0.17,'q' => 0.11,'j' => 0.10,'z' => 0.07,
}
# FREQS = {"e"=>11.759, "t"=>8.753, "a"=>8.542, "o"=>8.006, "i"=>7.445,
#   "n"=>7.143, "r"=>6.805, "s"=>5.652, "l"=>4.406, "h"=>4.036, "c"=>3.666,
#   "d"=>3.479, "u"=>2.946, "m"=>2.771, "p"=>2.417, "f"=>2.23, "y"=>2.036,
#   "g"=>2.034, "b"=>1.667, "w"=>1.6, "v"=>1.119, "k"=>0.763, "x"=>0.271,
#   "j"=>0.242, "q"=>0.113, "z"=>0.1}
LETTERS = "bcdfghjklmnpqrstvwxyz".chars.to_a

triangles = JSON.load(IO.read("data/triangles.json"))
matrix = YAML.load(IO.read('data/pairs.yml'))

# Score triangles by letter frequency
def score(tri)
  tri.chars.map { |e| FREQS[e] }.inject(:+)
end

# Find chording triangle pair

def intersect?(t1,t2)
  t1.chars.any? {|c| t2.include?(c)}
end

def decent_pair(t1,t2, matrix)
  sum = 0
  t1.chars.each do |c1|
    t2.chars.each do |c2|
      sum += matrix[c1][c2]
    end
  end
  sum
end

def find_chord_pair(triangles, matrix)
  decent = []
  triangles.each do |ta1|
    triangles.each do |ta2|
      t1 = ta1[0]; t2 = ta2[0]
      next if intersect?(t1,t2)
      s = decent_pair(t1,t2, matrix)
      decent << [t1,t2, s] if s < 0.01
    end
  end
  decent
end

def score_pair(t1,t2)
  score(t1) + score(t2)
end

def interactive_lookup
  loop do
    print ">> "
    q = gets.chomp
    break if q == 'exit'
    puts "Score: #{score(q)}"
    puts "Probability: #{}"
  end
end

def all_pairs(triangles)
  all = []
  triangles.each do |ta1|
    triangles.each do |ta2|
      t1 = ta1[0]; t2 = ta2[0]
      next if intersect?(t1,t2)
      all << [t1,t2]
    end
  end
  all
end

# Scoring based on collisions with non-allocated letters
def score_letter(c, others, matrix)
  score = 0
  others.each do |c2|
    score += matrix[c][c2]
  end
  score
end

def score_pair_others(t1,t2,left,matrix)
  s = 0
  others = left - t1.chars.to_a
  t1.chars.each do |c|
    s += score_letter(c, others,matrix)
  end
  others = left - t2.chars.to_a
  t2.chars.each do |c|
    s += score_letter(c, others,matrix)
  end
  s
end


decided = ['h', 'dft', 'lmn']
# decided = ['h']
candidates = triangles.reject {|t| decided.any? {|t2| intersect?(t[0],t2)} }
# candidates.map {|t| t + [score(t[0])]}.sort_by {|t| -t[2]}.take(30).each {|t| p t}

# decent = find_chord_pair(candidates, matrix)
# decent.map {|t| t + [score_pair(t[0],t[1]), score(t[0]), score(t[1])]}.sort_by {|t| -t[3]}.take(30).each {|t| p t}
left = LETTERS - decided.join('').chars.to_a
pairs = all_pairs(candidates)
pairs.map! {|p| p + [score_pair_others(p[0],p[1],left,matrix)]}
pairs.select! {|p| p[2] < 0.035}
pairs.map! {|p| p + [score_pair(p[0],p[1]), score(p[0]), score(p[1])]}
pairs.sort_by! {|p| -p[3]}
pairs.take(15).each {|t| p t}

stats = Aggregate.new(0,10,1)
pairs.each {|p| stats << (p[2]*100).round}
puts "#{pairs.length} candidates with average score #{stats.mean}"
puts stats.to_s

puts score_pair_others("jkr","cpt", "bdgwmqvxjkrcpt".chars.to_a,matrix)

# interactive_lookup
