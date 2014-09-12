json.array!(@sites) do |site|
  json.extract! site, :id, :name, :last_success
  json.url site_url(site, format: :json)
end
