class CreateClockings < ActiveRecord::Migration
  def change
    create_table :clockings do |t|
    	t.integer :runner_id
    	t.string :direction
    	t.timestamps
    end
  end
end
