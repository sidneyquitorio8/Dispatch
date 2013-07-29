class DeviseCreateRunners < ActiveRecord::Migration
  def change
    create_table(:runners) do |t|
      t.string :login, null: false, default: "", unique: true
      t.string :name
      t.string :cell
      t.boolean :send_text, default: false
      t.boolean :send_email, default: true
      t.boolean :admin, default: false
      t.boolean :available, default: false
      
      ## Devise db authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Devise recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Devise rememberable
      t.datetime :remember_created_at

      ## Devise trackable
      t.integer  :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps
    end

    add_index :runners, :email,                :unique => true
    add_index :runners, :reset_password_token, :unique => true
  end
end