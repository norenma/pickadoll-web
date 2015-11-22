class AnswersController < ApplicationController
  protect_from_forgery with: :null_session,
                       if: proc { |c| c.request.format == 'application/json' }
  respond_to :json, :xml, :html, :js

  def index
    @answers = Answer.all
  end

  def show
    id = params[:id]
    @questionnaire = Questionnaire.find(id)

    if authenticate_user
      @curr_user = User.find(session[:user_id])
      @username = @curr_user.username
    end

    @answers = Answer.select('tester_id, COUNT(id) as numberOfAnswers, MAX(answer_time) as lastAnswer').where(questionnaire: id).group('tester_id')
  end

  def generate_csv
    data = []
    tester_ids = params[:answer]

    if !tester_ids
      flash.alert = 'Du måste välja en fråga vars resultat ska sparas.'
      redirect_to :back
    else
      tester_ids.each do |id|
        id_results = Answer.where(tester_id: id)
        data.push(id_results)
      end

      answer_csv = CSV.generate do |csv|
        csv << %w(TestID Fråga Svar Svarsvärde Svarstid)
        # loop
        data.each do |d|
          d.each do |r|
            question_label = Question.where(id: r.question).pluck(:text)
            csv << [r.tester_id, question_label[0], r.answer_label,
                    r.answer_value, r.answer_time]
          end
        end
      end

      send_data(answer_csv, type: 'text/csv', filename: 'resultat.csv')
    end
  end
end
