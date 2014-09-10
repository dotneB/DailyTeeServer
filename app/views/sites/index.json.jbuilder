json.array!(@sites) do |site|
  json.extract! site, :id, :name, :last_success, :last_failure
  json.url site_url(site, format: :json)
end
