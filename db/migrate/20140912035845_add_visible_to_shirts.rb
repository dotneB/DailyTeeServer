class AddVisibleToShirts < ActiveRecord::Migration
  def change
    add_column :shirts, :visible, :boolean
  end
end
