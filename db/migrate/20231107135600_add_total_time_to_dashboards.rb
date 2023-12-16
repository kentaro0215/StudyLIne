# frozen_string_literal: true

class AddTotalTimeToDashboards < ActiveRecord::Migration[7.0]
  def change
    add_column :dashboards, :total_time, :integer
  end
end
