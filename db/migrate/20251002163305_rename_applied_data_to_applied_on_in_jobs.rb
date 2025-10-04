class RenameAppliedDataToAppliedOnInJobs < ActiveRecord::Migration[8.0]
  def change
     rename_column :jobs, :applied_data, :applied_on
  end
end
