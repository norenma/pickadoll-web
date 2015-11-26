class AddQuestionnaireToResponseOption < ActiveRecord::Migration
  def change
    add_reference :response_options, :questionnaire, index: true
  end
end
