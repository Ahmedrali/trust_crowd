json.array!(@problems) do |problem|
  json.extract! problem, :name, :desc, :tw_hash
  json.url problem_url(problem, format: :json)
end
