class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.datetime :last_success
      t.datetime :last_failure

      t.timestamps
    end
  end
end
