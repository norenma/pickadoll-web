class QuestionnairesController < ApplicationController
	def index
		@questionnaires = Questionnaire.where(user_id: session[:user_id])

		@answers = Answer.select("questionnaire as questionnaire_id, COUNT(id) as numberOfAnswers,
			MAX(answer_time) as lastAnswerTime").where(user: session[:user_id]).group("questionnaire")

		@questionnaireData = []
		#ful-lösning pga kass struktur på grejer
		@questionnaires.each do |q|
			@questionnaireData.push({
				'id' => q.id,
				'name' => q.name,
				'description' => q.description,
				'owner' => User.where(id: q.user_id).pluck(:username),
				'numberOfAnswers' => Answer.select('COUNT(id) as numberOfAnswers').where(questionnaire: q.id),
				'created_at' => q.created_at
			})
		end
		#@questionnairesWithResults = Questionnaire.find()

		if authenticate_user()
			@curr_user = User.find(session[:user_id])
			@username = @curr_user.username
		end
	end

	def new
		@questionnaire = Questionnaire.new
		#Just create the questionnaire
		create()
	end

	def update
		@questionnaire = Questionnaire.find(params[:id])
		puts "updating questionnaire: #{@questionnaire.inspect}"
		puts "params: #{questionnaire_params}"

		if @questionnaire.update(questionnaire_params)
			redirect_to questionnaires_path
		else
			render 'edit'
		end
	end

	def show
		herp = 123

		if herp == 123
			@questionnaires = Questionnaire.find(params[:id])
			respond_to do |format|
	    		format.html # show.html.erb
	    		format.json  { render :json => @questionnaires }
	    		format.xml  { render :xml => @questionnaires }
	    	end
		else

		end
	end

	def create
		@questionnaire = Questionnaire.new()
		@questionnaire.name = 'Ny survey'
		@questionnaire.user_id = session[:user_id]
		@questionnaire.save

		@category = Category.new

		@category.name = 'Alla'
		#@category.description = 'Alla frågor för enkäten ' + @questionnaire.name
		@category.questionnaire_id_id = Integer(@questionnaire[:id])
		@category.order = 0
		@category.image = 'img/all.png'

		@category.save

		redirect_to edit_questionnaire_path(@questionnaire.id)
		#render plain: @questionnaire.inspect
	end

	def edit
		@questionnaire = Questionnaire.find(params[:id])
		@categories = Category.where(questionnaire_id_id: params[:id]).order(order: :asc)
		@catids = []
		puts "\nediting: #{@questionnaire.inspect}"

		@categories.each do |c|
			@catids.push c.id
		end

		@questions = Question.where(category_id: @catids).order(order: :asc)

		@questionnaire_id = @questionnaire.id

		@response_options = ResponseOption.all

		#if you want to create a new response option
		@response_option = ResponseOption.new

		if authenticate_user()
			@curr_user = User.find(session[:user_id])
			@username = @curr_user.username
		end
		#render plain: @questionnaire.inspect
	end

	def destroy
		@questionnaire = Questionnaire.find(params[:id])
		@questionnaire.destroy

		redirect_to questionnaires_path
	end

	def clone
		puts "Cloning questionnaire: \n#{@questionnaire.to_yaml}"

		@qid = params[:id]
		@questionnaire = Questionnaire.find(@qid)
		@categories = Category.where(questionnaire_id_id: @qid).order(order: :asc)

		# Copy questionnaire
		@new_questionnaire = @questionnaire.dup
		@new_questionnaire.name = "Kopia av #{@new_questionnaire.name}"
		@new_questionnaire.save

		@categories.each do |c|
			# puts "Category: \n#{c.to_yaml}"

			# Copy category
			new_cat = c.dup
			new_cat.questionnaire_id_id = @new_questionnaire.id
			new_cat.save

			questions = Question.where(category_id: c.id)
			questions.each do |q|
				# puts "Question: \n#{q.to_yaml}"

				# Copy question
				new_quest = q.dup
				new_quest.category_id = new_cat.id
				new_quest.save
			end

			new_cat.save

		end

		@new_questionnaire.save

		redirect_to questionnaires_path
	end

	def addNewCategory
		@qid = params[:id]
		@lastOrderCategory = Category.where(questionnaire_id_id: @qid).order(order: :desc).first

		if @lastOrderCategory
			@orderVal = @lastOrderCategory.order + 1
		else
			@orderVal = 1
		end

		@category = Category.new
		@category.order = @orderVal
		@category.name = "Ny kategori "
		@category.questionnaire_id_id = @qid

		@category.save

		render json: @category
	end

	def updateCategoryOrder
		@catOrder = params[:catOrder]
		v = 1
		for i in @catOrder do
			#strtest << "Question %s in position %s" % [i, v]
			c = Category.find(i)

			c.order = v
			c.save
			v = v + 1
		end

		render json: @catOrder
	end

	def setResponseOptionForAllQuestions
		questionnaireId = params[:id]
		responseOptionId = params[:responseOption]

		@questionnaire = Questionnaire.find(params[:id])
		@categories = Category.where(questionnaire_id_id: params[:id]).order(order: :asc)
		@catids = []
		@categories.each do |c|
			@catids.push c.id
		end

		@questions = Question.where(category_id: @catids)

		@questions.each do |q|
			q.response_id = responseOptionId

			q.save
		end

		response = {
			'questionnaireId' => questionnaireId,
			'responseOptionId' => responseOptionId
		}

		render json: response
	end

	private
		def questionnaire_params
			#params.require(:question).permit(:name, :text, :media_files)
			params.require(:questionnaire).permit(:name, :description)
		end
end
