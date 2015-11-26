class AddSubjectToRight < ActiveRecord::Migration
  def change
    add_column :rights, :subject_id, :integer
  end
end
