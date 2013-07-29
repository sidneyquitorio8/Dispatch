class CreateAuthorizedRunners < ActiveRecord::Migration
  def change
    create_table :authorized_runners do |t|
      t.string :login

      t.timestamps
    end
  end
end
