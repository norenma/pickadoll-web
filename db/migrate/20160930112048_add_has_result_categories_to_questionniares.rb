class AddHasResultCategoriesToQuestionniares < ActiveRecord::Migration
  def change
    add_column :questionnaires, :has_result_categories, :boolean
  end
end
