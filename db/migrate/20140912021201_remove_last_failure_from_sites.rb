class RemoveLastFailureFromSites < ActiveRecord::Migration
  def change
    remove_column :sites, :last_failure, :datetime
  end
end
