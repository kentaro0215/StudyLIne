class RenameDashboardToStudyRecords < ActiveRecord::Migration[7.0]
  def change
    rename_table :dashboards, :study_records
  end
end
