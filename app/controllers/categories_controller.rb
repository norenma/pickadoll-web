class CategoriesController < ApplicationController
  protect_from_forgery with: :null_session,
                       if: proc { |c| c.request.format == 'application/json' }
  # respond_to :json, :xml, :html, :js

  def index
    @questid = params[:questionnaire_id]
  end

  def update_time(id)
    @questionnaire = Questionnaire.find(id)
    @questionnaire.update(updated_at: DateTime.now)
  end

  def update
    @category = Category.find(params[:id])
    update_time(@category.questionnaire_id_id)
    if @category.update(category_params)
      redirect_to questionnaires_path
    else
      render 'edit'
    end
  end

  def update_order
    @category = Category.find(params[:id])
    update_time(@category.questionnaire_id_id)
    @order = params[:questOrder]

    v = 1
    for i in @order do
      # strtest << "Question %s in position %s" % [i, v]
      q = Question.find(i)

      q.order = v
      q.category_id = params[:id]
      q.save
      v += 1
    end

    # @category = Category.find(params[:questOrder])
    # render :json => @category.inspect

    respond_to do |format|
      format.json { render json: @order }
      # format.html {render json: @category }
    end
  end

  def remove_image
    p('remove img!')
    @c_id = params[:cat_id]
    @cat = Category.find(@c_id)
    update_time(@cat.questionnaire_id_id)
    @cat.image = 0
    @cat.save
    render json: @c_id
  end

  def remove_audio
    p('remove audio!')
    @c_id = params[:cat_id]
    @cat = Category.find(@c_id)
    update_time(@cat.questionnaire_id_id)
    @cat.audio = 0
    @cat.save
    render json: @c_id
  end


  def upload_image
    @img_file = params[:category_image]
    @c_id = params[:category][:id]



    if !@img_file.nil?
      File.open(Rails.root.join('public', 'uploads',
                                @img_file.original_filename), 'wb') do |file|
        file.write(@img_file.read)
        @media_path = File.basename(file.path) # file.path
        now_time = Time.now.to_i
        image_file_name = 'image_' + now_time.to_s + File.extname(file)
        # rename the uploaded file
        new_file_name = Rails.root.join('public', 'uploads', image_file_name)
        File.rename(file, new_file_name)
        # render text: @media_path
        @media_files = MediaFile.create(
          media_type: 'img',
          ref: image_file_name
        )
        @media_files.save
        # get the id of the inserted mediafile
        @img_id = MediaFile.last.id
        # save the img to the question
        @cat = Category.find(@c_id)
        @cat.image = @img_id
        update_time(@cat.questionnaire_id_id)
        @cat.save
        @media_res = MediaFile.find(@img_id)
        render json: @media_res
      end
    else
      render plain: 'Error'
    end
    # render plain: params.inspect
  end

  def upload_audio
    @audio_file = params[:category_audio]
    @c_id = params[:category][:id]

    if !@audio_file.nil?
      File.open(Rails.root.join('public', 'uploads',
                                @audio_file.original_filename), 'wb') do |file|
        file.write(@audio_file.read)
        @media_path = File.basename(file.path)
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
        @audio_id = MediaFile.last.id
        @cat = Category.find(@c_id)
        @cat.audio = @audio_id
        update_time(@cat.questionnaire_id_id)
        @cat.save
        @media_res = MediaFile.find(@audio_id)
        render json: @media_res
      end
    else
      render plain: 'Nothing to upload '
    end
    # render plain: params.inspect
  end

  def add_new_question_to_category
    @quest = Question.new
    @last_quest = Question.where(category_id: params[:catid]).order(order: :desc).first
    @quest.category_id = params[:catid]
    @catid = params[:catid]
    @cat = Category.find(@catid)
    update_time(@cat.questionnaire_id_id)
    @resp_opts = ResponseOption.all
    # need to set order value as well
    if @last_quest
      @quest.order = @last_quest.order + 1
    else
      @quest.order = 1
    end

    @quest.save

    response = {
      'quest' => @quest.to_json,
      'catid' => @catid,
      'questid' => Category.find(params[:catid]).questionnaire_id_id,
      'response_options' => @resp_opts
    }

    render json: response
  end

  def destroy
    delete_category(params[:id])
  end

  def list
    search_string = params[:search_string] || ''

    @categories = Category.all
    user_id = session[:user_id]

    result = []
    @categories.each do |cat|
      questionnaire = Questionnaire.find(cat.questionnaire_id_id) rescue nil

      # Ignore this category if it doesn't belong to a questionnaire
      next unless questionnaire

      right = Right.where(subject_id: user_id,
                          questionnaire_id: questionnaire.id).first
      # Ignore this questionnaire if user has no right to see it
      next unless questionnaire.user_id == user_id || right

      # Ignore this category if it doesn't match the search
      search_names = [cat.name, questionnaire.name]
      next unless search_string == '' ||
                  search_names.any? { |str| str =~ /#{search_string}/i }

      result << {
        id: cat.id,
        name: cat.name,
        quest_name: questionnaire.name
      }
    end

    # Sort results by questionnaire name
    result.sort_by! { |e| e[:quest_name] }

    render json: result
  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end

  def delete_category(id)
    # Questions that belongs to the category
    questions = Question.where(category_id: id)
    questions.each(&:destroy)

    category = Category.find(id)
    update_time(@category.questionnaire_id_id)
    category.destroy

    # Send some feedback
    feedback = { 'status' => 'removed', 'id' => params[:id],
                 'questions' => questions.to_json }
    render json: feedback
  end
end
