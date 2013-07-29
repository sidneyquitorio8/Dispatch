class RemoveNameFromJobs < ActiveRecord::Migration
  def up
    remove_column :jobs, :name
  end

  def down
    add_column :jobs, :name, :string
  end
end
