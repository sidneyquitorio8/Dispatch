class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :speed
      t.string :service
      t.text :suggestion
      t.integer :job_id

      t.timestamps
    end
  end
end
