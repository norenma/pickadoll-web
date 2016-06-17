class QuestionnairesController < ApplicationController
  def index
    @questionnaires = Questionnaire.for_user_with_id(session[:user_id])

    @answers = Answer.select("questionnaire as questionnaire_id, COUNT(id) as numberOfAnswers,
      MAX(answer_time) as lastAnswerTime").where(user: session[:user_id]).group('questionnaire')

    if authenticate_user
      @curr_user = User.find(session[:user_id])
      @username = @curr_user.username
    end

    @questionnaire_data = []
    # ful-lösning pga kass struktur på grejer
    @questionnaire_data = @questionnaires.map do |q|
      { id: q.id,
        name: q.name,
        description: q.description,
        owner: User.where(id: q.user_id).pluck(:username),
        owned_by_user: q.user_id == @curr_user.id,
        number_of_answers: Answer.select('COUNT(id) as number_of_answers').where(questionnaire: q.id),
        created_at: q.created_at }
    end
    # @questionnairesWithResults = Questionnaire.find()
  end

  def new
    @questionnaire = Questionnaire.new
    # Just create the questionnaire
    create
  end

  def update
    @questionnaire = Questionnaire.find(params[:id])
    logger.info "updating questionnaire: #{@questionnaire.inspect}"
    logger.info "params: #{questionnaire_params}"

    if @questionnaire.update(questionnaire_params)
      redirect_to questionnaires_path
    else
      render 'edit'
    end
  end

  def show
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire_id = @questionnaire.id

    @categories = Category.where(questionnaire_id_id: @questionnaire.id).order(order: :asc)
    @cat_ids = @categories.map(&:id)

    @questions = Question.where(category_id: @cat_ids).order(order: :asc)

    @response_options = ResponseOption.visible_response_options(session[:user_id])

    if authenticate_user
      @curr_user = User.find(session[:user_id])
      @username = @curr_user.username
    end

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @questionnaire }
      format.xml { render xml: @questionnaire }
    end
  end

  def create
    # Make sure user is allowed to create/copy questionnaires
    @curr_user = User.find(session[:user_id]) if authenticate_user
    if @curr_user.create_questionnaire_permission
      @questionnaire = Questionnaire.new
      @questionnaire.name = 'Ny enkät'
      @questionnaire.user_id = session[:user_id]
      @questionnaire.save

      @category = Category.new

      @category.name = 'Alla'
      # @category.description = 'Alla frågor för enkäten ' + @questionnaire.name
      @category.questionnaire_id_id = Integer(@questionnaire[:id])
      @category.order = 0
      @category.image = 'img/all.png'

      @category.save

      redirect_to edit_questionnaire_path(@questionnaire.id)
      # render plain: @questionnaire.inspect
    else
      redirect_to questionnaires_path
    end
  end

  def edit
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire_id = @questionnaire.id

    user_right = user_right_to_questionnaire(session[:user_id], @questionnaire.id)
    redirect_to questionnaire_path(@questionnaire.id) unless user_right == :rw

    @categories = Category.where(questionnaire_id_id: @questionnaire.id).order(order: :asc)
    @cat_ids = @categories.map(&:id)

    @questions = Question.where(category_id: @cat_ids).order(order: :asc)

    @response_options = ResponseOption.visible_response_options(session[:user_id])

    # if you want to create a new response option
    @response_option = ResponseOption.new

    if authenticate_user
      @curr_user = User.find(session[:user_id])
      @username = @curr_user.username
    end

    # render plain: @questionnaire.inspect
  end

  def destroy
    #puts "destroy!!"
    # # Questions that belongs to the category
    categories = Category.where(questionnaire_id_id: params[:id])
    #puts categories
    categories.each do |cat|
      questions = Question.where(category_id: cat.id)
      questions.each(&:destroy)
    end
    categories.each(&:destroy)
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.destroy

    redirect_to questionnaires_path
  end

  def clone
    @qid = params[:id]
    @questionnaire = Questionnaire.find(@qid)
    @categories = Category.where(questionnaire_id_id: @qid).order(order: :asc)

    # Make sure user is allowed to create/copy questionnaires
    @curr_user = User.find(session[:user_id]) if authenticate_user
    if @curr_user.create_questionnaire_permission
      # Copy questionnaire
      @new_questionnaire = @questionnaire.dup
      @new_questionnaire.name = "Kopia av #{@new_questionnaire.name}"
      @new_questionnaire.user_id = session[:user_id] # Make current user the owner
      @new_questionnaire.save

      @categories.each do |c|
        # Copy category
        new_cat = c.dup
        new_cat.questionnaire_id_id = @new_questionnaire.id
        new_cat.save

        questions = Question.where(category_id: c.id)
        questions.each do |q|
          # Copy question
          new_quest = q.dup
          new_quest.category_id = new_cat.id
          new_quest.save
        end

        new_cat.save
      end

      @new_questionnaire.save
    end

    redirect_to questionnaires_path
  end

  def add_new_category
    @qid = params[:id]

    @category = Category.new
    @category.order = last_category_order_for_id(@qid)
    @category.name = 'Ny kategori'
    @category.questionnaire_id_id = @qid

    @category.save

    render json: @category
  end

  def update_category_order
    @cat_order = params[:catOrder]

    @cat_order.each_with_index do |e, i|
      c = Category.find(e)
      c.order = i
      c.save
    end

    render json: @cat_order
  end

  def add_existing_category
    questionnaire_id = params[:id]
    category_id = params[:cat_id]
    logger.debug "Qid: #{questionnaire_id}, Catid: #{category_id}"

    c = Category.find(category_id)

    # Copy category
    @category = c.dup
    @category.order = last_category_order_for_id(questionnaire_id)
    @category.questionnaire_id_id = questionnaire_id
    @category.save

    questions = Question.where(category_id: c.id)
    questions.each do |q|
      # Copy question
      new_quest = q.dup
      new_quest.category_id = @category.id
      new_quest.save
    end

    @category.save

    render js: "window.location = '#{edit_questionnaire_path(questionnaire_id)}'"
  end

  def add_existing_question
    questionnaire_id = params[:id]
    category_id = params[:cat_id]
    question_id = params[:quest_id]
    logger.debug "Qid: #{questionnaire_id}, Catid: #{category_id}, Questid: #{question_id}"

    c = Category.find(category_id)
    q = Question.find(question_id)

    # Copy question
    @question = q.dup
    @question.order = last_question_order_for_id(c.id)
    @question.category_id = c.id
    @question.save

    render js: "window.location = '#{edit_questionnaire_path(questionnaire_id)}'"
  end

  def set_response_option_for_all_questions
    questionnaire_id = params[:id]
    response_option_id = params[:responseOption]

    @questionnaire = Questionnaire.find(params[:id])
    @categories = Category.where(questionnaire_id_id: params[:id]).order(order: :asc)
    @cat_ids = []
    @categories.each do |c|
      @cat_ids.push c.id
    end

    @questions = Question.where(category_id: @cat_ids)

    @questions.each do |q|
      q.response_id = response_option_id

      q.save
    end

    # Let response option be shown everywhere (since it is selected for all)
    @response_option = ResponseOption.find(response_option_id)
    @response_option.availability = true
    @response_option.save

    response = {
      'questionnaireId' => questionnaire_id,
      'responseOptionId' => response_option_id
    }

    render json: response
  end

  private

  def questionnaire_params
    # params.require(:question).permit(:name, :text, :media_files)
    params.require(:questionnaire).permit(:name, :description)
  end

  def user_right_to_questionnaire(user_id, questionnaire_id)
    # Check if questionnaire is owned by user
    questionnaire = Questionnaire.find(questionnaire_id)
    return :rw if questionnaire.user_id == user_id

    # Otherwise, check if user has a right to read/write questionnaire
    right = Right.where(subject_id: user_id, questionnaire_id: questionnaire_id).first
    return right.level.to_sym if right

    nil
  end

  def last_category_order_for_id(id)
    last_order_category = Category.where(questionnaire_id_id: id).order(order: :desc).first
    last_order_category ? last_order_category.order + 1 : 1
  end

  def last_question_order_for_id(id)
    last_order_question = Question.where(category_id: id).order(order: :desc).first
    last_order_question ? last_order_question.order + 1 : 1
  end
end
