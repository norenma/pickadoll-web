class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :response_options, :owned_by_question, :question_id
  end
end
