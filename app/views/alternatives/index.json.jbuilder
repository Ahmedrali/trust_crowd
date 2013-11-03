json.array!(@alternatives) do |alternative|
  json.extract! alternative, :name, :desc, :tw_hash, :problem_id
  json.url alternative_url(alternative, format: :json)
end
