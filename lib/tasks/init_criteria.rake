require "matrix"

desc "Get the tweets for each problem and its corresponding alternatives and criteria"
task :tests => :environment do
  p = Problem.active.first
  criteria = {}
  p.criteria.each do |criterium|
    criteria.include?(criterium.parent_id) ? criteria[criterium.parent_id].append([criterium.name, criterium.id]) : (criteria[criterium.parent_id] = [[criterium.name, criterium.id]])
  end
  puts criteria
  res = buildTree(criteria)
  puts res.join("; ")
end

def buildTree(src)
  res = src.delete(-1)
  depth = 1
  while src.count > 0
    str = "-"*depth
    tmp = []
    res.each do |c|
      if src.include?(c[1])
        tmp.concat( [c].concat(src[c[1]].map{|s| ["#{str}> #{s[0]}", s[1]] }) )
        src.delete(c[1])
      else
        tmp.append(c)
      end
    end
    res = tmp.clone
    depth += 1
  end
  res
end