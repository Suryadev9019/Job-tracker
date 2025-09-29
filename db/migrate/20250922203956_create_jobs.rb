class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.string :company
      t.string :location
      t.text :description
      t.string :status
      t.date :applied_data
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
