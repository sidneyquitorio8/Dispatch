class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
    	t.integer :job_id
    	t.integer :runner_id
      t.integer :est_time
      t.datetime :on_it_at
      t.datetime :assigned_at
      t.timestamps
    end
  end
end