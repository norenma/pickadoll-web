class CategoriesController < ApplicationController
	protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
	#respond_to :json, :xml, :html, :js
	
	def index 
		@questid = params[:questionnaire_id]
	end

	def update 
		@category = Category.find(params[:id])

		if @category.update(category_params)
			redirect_to questionnaires_path
		else 
			render 'edit'
		end
	end 

	def updateOrder 
		@category = Category.find(params[:id])
		@order = params[:questOrder] 
		
		v = 1 
		for i in @order do
			#strtest << "Question %s in position %s" % [i, v] 
			q = Question.find(i)

			q.order = v
			q.category_id = params[:id]
			q.save 
			v = v + 1 
		end 

		#@category = Category.find(params[:questOrder])
		#render :json => @category.inspect

		respond_to do |format|
  			format.json { render json: @order }
  			#format.html {render json: @category }
 		end
	end 

	def uploadImage 
		@imgf = params[:category_image]
		@cid = params[:category][:id]

		if @imgf != nil 
			File.open(Rails.root.join('public', 'uploads', 
				@imgf.original_filename), 'wb') do |file| 
					file.write(@imgf.read)
					@media_path = File.basename(file.path) #file.path 


					currTime = Time.now.to_i
					imageFileName = 'image_' + currTime.to_s + File.extname(file)
					#rename the uploaded file 
					newFileName =  Rails.root.join('public', 'uploads', imageFileName) 
					File.rename(file, newFileName) 

					#render text: @media_path
					@mfiles = MediaFile.create(
						media_type: 'img', 
						ref: imageFileName
					)
					@mfiles.save 
					#get the id of the inserted mediafile 
					@imgid = MediaFile.last.id
					#save the img to the question 
					@cat = Category.find(@cid)
					@cat.image = @imgid
					@cat.save 

					@medRes = MediaFile.find(@imgid)
					render json: @medRes 
				end
		else 
			render plain: "Error"
		end
		#render plain: params.inspect
	end 

	def uploadAudio 
		@audFile = params[:category_audio]
		@cid = params[:category][:id]

		if @audFile != nil
			File.open(Rails.root.join('public', 'uploads', 
				@audFile.original_filename), 'wb') do |file|
					file.write(@audFile.read)
					@media_path = File.basename(file.path)

					currTime = Time.now.to_i
					audioFileName = 'audio_' + currTime.to_s + File.extname(file) 
					#rename the uploaded file 
					newFileName =  Rails.root.join('public', 'uploads', audioFileName) 
					File.rename(file, newFileName) 

					@mfiles = MediaFile.create(
						media_type: 'audio', 
						ref: audioFileName
					)
					@mfiles.save 

					@audid = MediaFile.last.id
					@cat = Category.find(@cid)
					@cat.audio = @audid
					@cat.save 

					@medRes = MediaFile.find(@audid)
					render json: @medRes
				end 
		else 
			render plain: "Nothing to upload "
		end 
		#render plain: params.inspect
	end 

	def addNewQuestionToCategory
		@quest = Question.new
		@lastQuest = Question.where(category_id: params[:catid]).order(order: :desc).first
		@quest.category_id  = params[:catid]	
		@catid = params[:catid]
		@respOpts = ResponseOption.all 
		#need to set order value as well 
		if @lastQuest 
			@quest.order = @lastQuest.order + 1 
		else 
			@quest.order = 1
		end 

		@quest.save 

		response = {
			'quest' => @quest.to_json, 
			'catid' => @catid,  
			'questid' => Category.find(params[:catid]).questionnaire_id_id, 
			'response_options' => @respOpts
		}
		
		render json: response 
	end 

	def destroy 
		deleteCategory(params[:id])
	end 

	private 
		def category_params
			params.require(:category).permit(:name, :description)
		end


		def deleteCategory(id) 
			#Questions that belongs to the category 
			questions = Question.where(category_id: id)
			questions.each do |q| 
				q.destroy
			end 

			category = Category.find(id)
			category.destroy 

			#Send some feedback 
			feedback = {'status' => 'removed', 'id' => params[:id], 'questions' => questions.to_json }  
			render json: feedback
		end 
end
