require "matrix"

desc "Test some tasks"
task :tests => :environment do
  
end

def mapSum(map1, map2)
  res = {}
  map1.keys().each do |k|
    res[k] = map1[k]+map2[k]
  end
  res
end

def mapSub(map1, map2)
  res = {}
  map1.keys().each do |k|
    res[k] = map1[k]-map2[k]
  end
  res
end

def mapProd(map1, map2)
  res = {}
  map1.keys().each do |k|
    res[k] = map1[k]*map2[k]
  end
  res
end

def mapSumProd(map1, map2)
  res = 0
  map1.keys().each do |k|
    res += map1[k]*map2[k]
  end
  res
end

