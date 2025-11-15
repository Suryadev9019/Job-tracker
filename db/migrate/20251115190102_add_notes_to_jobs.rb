class AddNotesToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :notes, :text
  end
end
