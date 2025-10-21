class CreateSleeps < ActiveRecord::Migration[7.2]
  def change
    create_table :sleeps do |t|
      t.bigint :user_id, null: false
      t.datetime :clock_in_time
      t.datetime :clock_out_time
      t.integer :duration_minutes

      t.timestamps
    end

    add_index :sleeps, :user_id
    add_index :sleeps, :clock_in_time
    add_index :sleeps, :clock_out_time
    add_index :sleeps, [ :user_id, :clock_in_time, :duration_minutes ]
    add_index :sleeps, :duration_minutes, order: { duration_minutes: :desc }, where: "(clock_out_time IS NOT NULL)"
    add_index :sleeps, :user_id, unique: true, name: "index_sleeps_on_user_id_clock_out_time_null", where: "(clock_out_time IS NULL)"
    add_foreign_key :sleeps, :users
  end
end
