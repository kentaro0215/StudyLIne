# frozen_string_literal: true

class UpdateDashboardTags < ActiveRecord::Migration[7.0]
  def change
    rename_table :dashboard_tags, :study_record_tags

    rename_column :study_record_tags, :dashboard_id, :study_record_id
  end
end
