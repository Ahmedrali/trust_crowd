json.array!(@criteria) do |criterium|
  json.extract! criterium, :name, :desc, :tw_hash, :problem_id, :alternatives_matrix, :alternatives_value, :weight
  json.url criterium_url(criterium, format: :json)
end
