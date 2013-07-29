class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :user_id
      t.integer :runner_id
      t.string :name
      t.string :status, default: 'unassigned'
      t.text :description
      t.string :location
      t.integer :response_count, default: 0
      t.boolean :buffer_ran, default: false
      t.boolean :reassigned, default: false
      t.datetime :assigned_at
      t.datetime :completed_at
      t.datetime :cancelled_at     
      t.timestamps
    end
  end
end