require "json"
require "yaml"

FREQS = {
'e' => 12.02,'t' => 9.10,'a' => 8.12,'o' => 7.68,'i' => 7.31,
'n' => 6.95,'s' => 6.28,'r' => 6.02,'h' => 5.92,'d' => 4.32,
'l' => 3.98,'u' => 2.88,'c' => 2.71,'m' => 2.61,'f' => 2.30,
'y' => 2.11,'w' => 2.09,'g' => 2.03,'p' => 1.82,'b' => 1.49,
'v' => 1.11,'k' => 0.69,'x' => 0.17,'q' => 0.11,'j' => 0.10,'z' => 0.07,
}
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
      decent << [t1,t2, s] if s < 0.003
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

# decent = find_chord_pair(triangles, matrix)
# decent.map {|t| t + [score_pair(t[0],t[1]), score(t[0]), score(t[1])]}.sort_by {|t| -t[3]}.take(30).each {|t| p t}

decided = ['ftv','dmw']
# decided = []
candidates = triangles.reject {|t| decided.any? {|t2| intersect?(t[0],t2)} }
candidates.map {|t| t + [score(t[0])]}.sort_by {|t| -t[2]}.take(30).each {|t| p t}

# pairs = all_pairs(candidates)
# pairs.map! {|p| p + [score_pair(p[0],p[1]), score(p[0]), score(p[1])]}
# pairs.sort_by! {|p| -p[2]}
# pairs.take(20).each {|t| p t}

# interactive_lookup
