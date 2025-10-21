class CreateDailySleepSummariesTable < ActiveRecord::Migration[7.2]
  def up
    # Create daily_sleep_summaries table with UUID primary key and foreign key to users table
    create_table :daily_sleep_summaries, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.date :date
      t.integer :total_sleep_duration_minutes
      t.integer :number_of_sleep_sessions
      t.timestamps
    end

    # Add indexes for daily_sleep_summaries table
    add_index :daily_sleep_summaries, [ :user_id, :date ], unique: true
    add_index :daily_sleep_summaries, [ :user_id, :total_sleep_duration_minutes, :date ]
  end

  def down
    drop_table :daily_sleep_summaries
  end
end
