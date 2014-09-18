class AddOriginalHashToShirts < ActiveRecord::Migration
  def change
    add_column :shirts, :original_hash, :string
    reversible do |dir|
      dir.up { Shirt.all do |s| s.update :original_hash => Digest::SHA1.base64digest(s.name + s.url + s.image_url) end }
    end
  end
end