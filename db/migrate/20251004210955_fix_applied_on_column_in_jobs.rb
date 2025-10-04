class FixAppliedOnColumnInJobs < ActiveRecord::Migration[8.0]
  def up
    # First, remove the old column if it exists
    remove_column :jobs, :applied_data if column_exists?(:jobs, :applied_data)
    remove_column :jobs, :applied_on if column_exists?(:jobs, :applied_on)
    
    # Then add the new column
    add_column :jobs, :applied_on, :date
  end

  def down
    remove_column :jobs, :applied_on
    add_column :jobs, :applied_data, :date
  end
end
