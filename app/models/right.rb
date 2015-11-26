class Right < ActiveRecord::Base
  enum level: [:r, :rw]
  belongs_to :questionnaire
  has_one :user, class: 'User'
  has_one :subject, class: 'User'
end
