class CreateUsersTable < ActiveRecord::Migration[7.2]
  def up
    # Enable UUID extension if not already enabled
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # Create users table with UUID primary key
    create_table :users, id: :uuid do |t|
      t.string :name
      t.timestamps
    end

    # Add index for name column
    add_index :users, :name
  end

  def down
    drop_table :users
  end
end
