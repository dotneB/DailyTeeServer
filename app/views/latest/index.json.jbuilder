json.array!(@shirts) do |shirt|
  json.extract! shirt, :id, :name, :url, :image_url, :created_at, :updated_at
  json.site do |json|
    json.(shirt.site, :id, :name)
  end
end
