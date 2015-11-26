class Questionnaire < ActiveRecord::Base
  def self.for_user_with_id(user_id)
    owned_questionnaires = Questionnaire.where(user_id: user_id)
    right_questionnaires = Right.where(subject_id: user_id).map do |r|
      Questionnaire.find(r.questionnaire_id)
    end
    owned_questionnaires | right_questionnaires
  end
end
