class CreateSleepsTable < ActiveRecord::Migration[7.2]
  def up
    # Create sleeps table with UUID primary key and foreign key to users table
    create_table :sleeps, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.datetime :clock_in_time
      t.datetime :clock_out_time
      t.integer :duration_minutes
      t.timestamps
    end

    # Add indexes for sleeps table
    add_index :sleeps, :clock_in_time
    add_index :sleeps, :clock_out_time
    add_index :sleeps, [ :user_id, :clock_in_time, :duration_minutes ]
    add_index :sleeps, :duration_minutes, order: { duration_minutes: :desc }, where: "(clock_out_time IS NOT NULL)"
    add_index :sleeps, :user_id, unique: true, name: "index_sleeps_user_id_clock_out_time_null", where: "(clock_out_time IS NULL)"
  end

  def down
    drop_table :sleeps
  end
end
