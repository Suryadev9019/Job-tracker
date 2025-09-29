class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.string :status
      t.date :applied_date
      t.references :user, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.references :resume, null: false, foreign_key: true

      t.timestamps
    end
  end
end
