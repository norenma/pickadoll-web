class AddRepresentCatToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :represent_category_id, :integer
  end
end
