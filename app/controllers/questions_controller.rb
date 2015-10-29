class QuestionsController < ApplicationController
	protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
	respond_to :json, :xml, :html, :js

	def index 
		@questions = Question.all
	end 

	def new 
		@questionnaire = Questionnaire.find(params[:questionnaire_id])
		@category = Category.find(params[:category_id])
		@question = Question.new
		@media_files = MediaFile.new
		#@question.media = Media.new
	end

	def create 		
		@question = Question.new(question_params)
		@question.category_id = params[:category_id]
		@question.save

		@imgf = params[:image_file]

		if @imgf != nil 
			File.open(Rails.root.join('public', 'uploads', 
				@imgf.original_filename), 'wb') do |file| 
					file.write(@imgf.read)
					media_path = File.basename(file.path) #file.path 
					#render text: @media_path
					@mfiles = @question.media_files.create(
						media_type: params[:media_files][:media_type], 
						ref: media_path
					)
					@mfiles.save

					redirect_to edit_questionnaire_path(params[:questionnaire_id])
					#redirect_to questions_path 
				end
		else 
			redirect_to edit_questionnaire_path(params[:questionnaire_id])
		end
	end  

	def edit 
		@questionnaire = Questionnaire.find(params[:questionnaire_id])
		@category = Category.find(params[:category_id])
		@qid = Integer(params[:id]) 
		#render plain: @qid.inspect

		@question = Question.find(params[:id])
		#:question_id => @qid
		@media_files = MediaFile.find_by question_id: @qid
	end 

	def show 
		@question = Question.find(params[:id])
	end 

	#method for handling the update of a question
	def update
		respond_to do |format| 
			@question = Question.find(params[:id])
			#@mfiles = @question.media_files.update(media_file_params)

			if params[:question_image]
				@questImg = params[:question_image]

				#upload image file to the uploads folder 
				File.open(Rails.root.join('public', 'uploads', 
				@questImg.original_filename), 'wb') do |file| 
					file.write(@questImg.read)
					media_path = File.basename(file.path)
					#render plain: @question.inspect
					#save details about the image in media_files 
					mfiles = MediaFile.create(
						media_type: 'img', 
						ref: media_path
					)
					mfiles.save 
					#get the id of the inserted mediafile 
					@imgid = MediaFile.last.id
					#render plain: mid 
				end
				#render plain: @questImg.inspect 
			else	 
				#Something else 
			end 

			if @question.update(question_params)

				if @imgid 
					@question.question_image = @imgid 
					@question.save 
				else 
				end 

				format.json { render :json => @question, :status => 200 } 
	            format.html { render :nothing => true, :notice => 'Update successful!' }  
			else 

			end 
		end 
	end

	def uploadImage 
		#respond_to do |format| 
		#render plain: params.inspect 
		if params[:question_image]
			@questImg = params[:question_image]
			@qid = params[:question][:id]

			#upload image file to the uploads folder 
			File.open(Rails.root.join('public', 'uploads', 
			@questImg.original_filename), 'wb') do |file| 
				file.write(@questImg.read)
				@media_path = File.basename(file.path)
				
				currTime = Time.now.to_i
				imageFileName = 'image_' + currTime.to_s + File.extname(file)
				#rename the uploaded file 
				newFileName =  Rails.root.join('public', 'uploads', imageFileName) 
				File.rename(file, newFileName) 

				#save details about the image in media_files 
				@mfiles = MediaFile.create(
					media_type: 'img', 
					ref: imageFileName
				)
				@mfiles.save 

				#get the id of the inserted mediafile 
				@imgid = MediaFile.last.id
				#save the img to the question 
				@quest = Question.find(@qid)
				@quest.question_image = @imgid
				@quest.save 

				@medRes = MediaFile.find(@imgid)
				render json: @medRes 
			end
		else	 

		end
		#end 
	end 

	def uploadAudio 
		if params[:question_audio]
			@questImg = params[:question_audio]
			@qid = params[:question][:id]

			#upload image file to the uploads folder 
			File.open(Rails.root.join('public', 'uploads', 
			@questImg.original_filename), 'wb') do |file| 
				file.write(@questImg.read)
				@media_path = File.basename(file.path)
				#save details about the image in media_files
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
				#get the id of the inserted mediafile 
				@imgid = MediaFile.last.id
				#save the img to the question 
				@quest = Question.find(@qid)
				@quest.question_audio = @imgid
				@quest.save 

				@medRes = MediaFile.find(@imgid)
				render json: @medRes 
			end
				#render plain: @questImg.inspect 
		else	 

		end
	end 

	def destroy 
		@question = Question.find(params[:id])
		@question.destroy

		feedback = {
			'status' => 'destroyed', 
			'id' => params[:id] 
		}
		#redirect_to questions_path
		render json: feedback
	end 

	private 
		#definierar vilka parametrar som är tillåtna för question
		def question_params 
			params.require(:question).permit(:name, :text, :response_id)
		end

		#permitted params for media_files
		def media_file_params 
			params.require(:media_files).permit(:media_type, :ref, :image_file)
		end 
end
