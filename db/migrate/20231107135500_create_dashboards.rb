class CreateDashboards < ActiveRecord::Migration[7.0]
  def change
    create_table :dashboards do |t|
      t.integer :user_id
      t.datetime :start_time
      t.datetime :finish_time

      t.timestamps
    end
    add_index :dashboards, :user_id
  end
end
