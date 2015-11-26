class ResponseOption < ActiveRecord::Base
  has_many :question

  def self.visible_response_options(user_id, question_id = nil)
    questionnaires = Questionnaire.for_user_with_id(user_id)

    response_options = questionnaires.map do |questionnaire|
      ResponseOption.where(questionnaire_id: questionnaire.id)
    end.flatten.uniq

    if question_id
      response_options.select { |r| r.availability || r.question_id == question_id }
    else
      response_options
    end
  end
end
