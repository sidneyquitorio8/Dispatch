class AddCategoryToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :category, :string
  end
end
