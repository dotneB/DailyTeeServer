class CreateShirts < ActiveRecord::Migration
  def change
    create_table :shirts do |t|
      t.string :name
      t.string :url
      t.string :image_url
      t.references :site, index: true

      t.timestamps
    end
  end
end
