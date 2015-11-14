class AddOwnedByQuestionToResponseOptions < ActiveRecord::Migration
  def change
    add_column :response_options, :owned_by_question, :integer
  end
end
