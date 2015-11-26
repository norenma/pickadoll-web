class AddQuestionnaireToRight < ActiveRecord::Migration
  def change
    add_reference :rights, :questionnaire, index: true
  end
end
