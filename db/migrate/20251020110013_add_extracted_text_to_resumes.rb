class AddExtractedTextToResumes < ActiveRecord::Migration[8.0]
  def change
    add_column :resumes, :extracted_text, :text
  end
end
