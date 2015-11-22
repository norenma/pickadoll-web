module Api
  class QuestionnairesController < ApplicationController
    protect_from_forgery with: :null_session,
                         if: proc { |c| c.request.format == 'application/json' }
    respond_to :json, :xml, :html, :js

    def index
      respond_with Questionnaire.all
    end

    def show
      respond_with Questionnaire.find(params[:id])
    end

    def post_results_from_app
      if params[:file]
        uploaded_file = params[:file]
        # tmp_file_path = File.absolute_path(uploaded_file.tempfile)
        answers = CSV.read(uploaded_file.tempfile)

        # render some response to the app
        render json: answers

        # create thread and deal with the new data that have been uploaded
        Thread.new do
          answers.each do |row|
            # things.push(row[0])
            answer = Answer.new
            answer.tester_id = row[0]
            answer.questionnaire = row[1]
            answer.question = row[2]
            answer.device_id = row[3]
            answer.answer_label = row[4]
            answer.answer_value = row[5]
            answer.answer_time = row[6]
            answer.user = row[7]
            answer.save
          end
        end
      else
        render plain: params.inspect
      end
    end

    def fetch
      @id = params[:id]
      # The questionnaire
      @quest = Questionnaire.find(@id)
      @categories = Category.where(questionnaire_id_id: @id).order(order: :asc)
      # very important name is right yes no change or else break
      # trademark protected name yes
      @super_array_that_is_an_object = {
        'questionnaire' => @quest,
        'categories' => [
        ],
        'response_options' => {
        },
        'media_files' => {
        }
      }

      @categories.each do |x|
        questions_for_category = Question.where(category_id: x.id)
        audio_file_ids = Question.where(category_id: x.id).uniq.pluck(:question_audio)
        image_file_ids = Question.where(category_id: x.id).uniq.pluck(:question_image)
        response_options_ids = questions_for_category.uniq.pluck(:response_id)
        response_options = ResponseOption.where(id: response_options_ids)

        category_audio_ids = Category.where(id: x.id).uniq.pluck(:audio)
        category_image_ids = Category.where(id: x.id).uniq.pluck(:image)
        # To be added to the superArray
        # resp_options_data = {}
        media_file_ids = audio_file_ids + image_file_ids + category_audio_ids +
                         category_image_ids
        media_file_ids = media_file_ids.uniq

        response_options.each do |opt|
          @super_array_that_is_an_object['response_options'][opt.id] = {
            'info' => opt,
            'response_items' => []
          }
          response_items = ResponseOptionItem.where(response_option_id: opt.id)

          @super_array_that_is_an_object['response_options'][opt.id]['response_items'] = response_items.to_json
          response_item_ids = response_items.uniq.pluck(:audio)

          media_file_ids += response_item_ids
        end

        media_files = MediaFile.where(id: media_file_ids)
        media_files.each do |media|
          @super_array_that_is_an_object['media_files'][media.id] = media
        end

        @super_array_that_is_an_object['categories'].push(
          'audio' => x.audio,
          'image' => x.image,
          'description' => x.description,
          'questions' => questions_for_category,
          'id' => x.id
        )
      end
      render json: @super_array_that_is_an_object
    end

    def fetch_all_for_user
      # stuff = { 'things' => 'Hej' }

      response = Questionnaire.where(user_id: params[:id])

      render json: response
    end
  end
end
