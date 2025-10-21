class CreateFollowsTable < ActiveRecord::Migration[7.2]
  def up
    # Create follows table with UUID primary key and foreign keys to users table
    create_table :follows, id: :uuid do |t|
      t.references :follower, type: :uuid, null: true, foreign_key: { to_table: :users }
      t.references :followed, type: :uuid, null: true, foreign_key: { to_table: :users }
      t.timestamps
    end

    # Add indexes for follows table
    add_index :follows, [ :follower_id, :followed_id ], unique: true
  end

  def down
    drop_table :follows
  end
end
