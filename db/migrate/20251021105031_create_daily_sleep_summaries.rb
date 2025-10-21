class CreateDailySleepSummaries < ActiveRecord::Migration[7.2]
  def change
    create_table :daily_sleep_summaries do |t|
      t.bigint :user_id, null: false
      t.date :date
      t.integer :total_sleep_duration_minutes
      t.integer :number_of_sleep_sessions

      t.timestamps
    end

    add_index :daily_sleep_summaries, :user_id
    add_index :daily_sleep_summaries, [ :user_id, :date ], unique: true
    add_index :daily_sleep_summaries, [ :user_id, :total_sleep_duration_minutes, :date ]
    add_foreign_key :daily_sleep_summaries, :users
  end
end
