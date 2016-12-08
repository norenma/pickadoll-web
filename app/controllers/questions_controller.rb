class QuestionsController < ApplicationController
  protect_from_forgery with: :null_session,
                       if: proc { |c| c.request.format == 'application/json' }
  respond_to :json, :xml, :html, :js

  def index
    @questions = Question.all
  end

  def new
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @category = Category.find(params[:category_id])
    @question = Question.new
    @media_files = MediaFile.new
    # @question.media = Media.new
  end

  def update_time(id)
    @question = Question.find(id)
    @cat = Category.find(@question.category_id)
    @questionnaire = Questionnaire.find(@cat.questionnaire_id)
    @questionnaire.update(updated_at: DateTime.now)
    puts("updated!")
    puts(@questionnaire)
    @questionnaire.save

  end

  def create
    @question = Question.new(question_params)
    @question.category_id = params[:category_id]
    @question.save

    update_time(@question.id)

    @image_file = params[:image_file]

    if !@image_file.nil?
      File.open(Rails.root.join('public', 'uploads',
                                @image_file.original_filename), 'wb') do |file|
        file.write(@image_file.read)
        media_path = File.basename(file.path) # file.path
        # render text: @media_path
        @media_files = @question.media_files.create(
          media_type: params[:media_files][:media_type],
          ref: media_path
        )
        @media_files.save
        redirect_to edit_questionnaire_path(params[:questionnaire_id])
        # redirect_to questions_path
      end
    else
      redirect_to edit_questionnaire_path(params[:questionnaire_id])
    end
  end

  def edit
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @category = Category.find(params[:category_id])
    @q_id = Integer(params[:id])
    # render plain: @q_id.inspect

    @question = Question.find(params[:id])
    #:question_id => @q_id
    @media_files = MediaFile.find_by question_id: @q_id
    puts("edit")
  end

  def show
    @question = Question.find(params[:id])
  end

  # method for handling the update of a question
  def update
    @question = Question.find(params[:id])
    # @media_files = @question.media_files.update(media_file_params)
    update_time(@question.id)
    if params[:question_image]
      @quest_img = params[:question_image]
      # upload image file to the uploads folder
      File.open(Rails.root.join('public', 'uploads',
                                @quest_img.original_filename), 'wb') do |file|
        file.write(@quest_img.read)
        media_path = File.basename(file.path)
        # render plain: @question.inspect
        # save details about the image in media_files
        media_files = MediaFile.create(
          media_type: 'img',
          ref: media_path
        )
        media_files.save
        # get the id of the inserted mediafile
        @img_id = MediaFile.last.id
        # render plain: mid
      end
      # render plain: @quest_img.inspect
    end

    respond_to do |format|
      if @question.update(question_params)
        if @img_id
          @question.question_image = @img_id
          @question.save
        end
        format.json { render json: @question, status: 200 }
        format.html { render nothing: true, notice: 'Update successful!' }
      end
    end
  end

  def remove_image
    p('remove img!')
    @q_id = params[:q_id]
    @q = Question.find(@q_id)
    update_time(@q_id)
    @q.question_image = 0
    @q.save
    render json: @q
  end

  def remove_audio
    p('remove audio!')
    @q_id = params[:q_id]
    @q = Question.find(@q_id)
    update_time(@q_id)

    @q.question_audio = 0
    @q.save
    render json: @q
  end

  def upload_image
    # respond_to do |format|
    # render plain: params.inspect
    if params[:question_image]
      @quest_img = params[:question_image]
      @q_id = params[:question][:id]

      # upload image file to the uploads folder
      File.open(Rails.root.join('public', 'uploads',
                                @quest_img.original_filename), 'wb') do |file|
        file.write(@quest_img.read)
        @media_path = File.basename(file.path)
        now_time = Time.now.to_i
        image_file_name = 'image_' + now_time.to_s + File.extname(file)
        # rename the uploaded file
        new_file_name = Rails.root.join('public', 'uploads', image_file_name)
        File.rename(file, new_file_name)
        # save details about the image in media_files
        @media_files = MediaFile.create(
          media_type: 'img',
          ref: image_file_name
        )
        @media_files.save
        # get the id of the inserted mediafile
        @img_id = MediaFile.last.id
        # save the img to the question
        @quest = Question.find(@q_id)
        @quest.question_image = @img_id
        @quest.save
        update_time(@quest.id)

        @media_res = MediaFile.find(@img_id)
        render json: @media_res
      end
    end
    # end
  end

  def upload_audio
    if params[:question_audio]
      @quest_audio = params[:question_audio]
      @q_id = params[:question][:id]

      # upload image file to the uploads folder
      File.open(Rails.root.join('public', 'uploads',
                                @quest_audio.original_filename), 'wb') do |file|
        file.write(@quest_audio.read)
        @media_path = File.basename(file.path)
        # save details about the image in media_files
        now_time = Time.now.to_i
        audio_file_name = 'audio_' + now_time.to_s + File.extname(file)
        # rename the uploaded file
        new_file_name = Rails.root.join('public', 'uploads', audio_file_name)
        File.rename(file, new_file_name)
        @media_files = MediaFile.create(
          media_type: 'audio',
          ref: audio_file_name
        )
        @media_files.save
        # get the id of the inserted mediafile
        @img_id = MediaFile.last.id
        # save the img to the question
        @quest = Question.find(@q_id)
        @quest.question_audio = @img_id
        @quest.save
        update_time(@quest.id)

        @media_res = MediaFile.find(@img_id)
        render json: @media_res
      end
      # render plain: @quest_audio.inspect
    end
  end

  def destroy
    update_time(params[:id])

    @question = Question.find(params[:id])
    @question.destroy

    feedback = {
      'status' => 'destroyed',
      'id' => params[:id]
    }
    # redirect_to questions_path
    render json: feedback
  end

  def list
    search_string = params[:search_string] || ''

    @questions = Question.all
    user_id = session[:user_id]
    puts("ID")
    puts(user_id)

    result = []
    @questions.each do |quest|
      cat = Category.find(quest.category_id) rescue nil
      # Ignore this question if it doesn't belong to a category
      next unless cat

      questionnaire = Questionnaire.find(cat.questionnaire_id) rescue nil
      # Ignore this category if it doesn't belong to a questionnaire
      next unless questionnaire

      right = Right.where(subject_id: user_id,
                          questionnaire_id: questionnaire.id).first
      # Ignore this questionnaire if user has no right to see it
      next unless questionnaire.user_id == user_id || right

      # Ignore this question if it doesn't match the search
      search_names = [quest.name, cat.name, questionnaire.name]
      next unless search_string == '' ||
                  search_names.any? { |str| str =~ /#{search_string}/i }

      result << {
        id: quest.id,
        name: quest.name,
        cat_name: cat.name,
        quest_name: questionnaire.name
      }
    end

    # Sort results by questionnaire name
    result.sort_by! { |e| e[:quest_name] }

    render json: result
  end

  private

  # definierar vilka parametrar som är tillåtna för question
  def question_params
    params.require(:question).permit(:name, :text, :response_id, :represent_category_id)
  end

  # permitted params for media_files
  def media_file_params
    params.require(:media_files).permit(:media_type, :ref, :image_file)
  end
end
