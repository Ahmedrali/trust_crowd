require "matrix"

desc "Get the tweets for each problem and its corresponding alternatives and criteria"
task :init_criteria => :environment do
  eval = {
          "BMW"=>{"Opel"=>1, "Audii"=>1, "Jeep"=>1}, 
          "Opel"=>{"Audii"=>1, "Jeep"=>1}, 
          "Audii"=>{"Jeep"=>1}
          }
  mat =  getMatrix(4, eval)
end

