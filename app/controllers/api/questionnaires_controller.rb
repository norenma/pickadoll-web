module Api
	class QuestionnairesController < ApplicationController
            protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
		respond_to :json, :xml, :html, :js

		def index
			respond_with Questionnaire.all

		end

		def show
        	   respond_with Questionnaire.find(params[:id])
      	end

            def postResultsFromApp 
                  if params[:file] 
                        uploadedFile = params[:file]
                        tmpFilePath = File.absolute_path(uploadedFile.tempfile)
                        answers = CSV.read(uploadedFile.tempfile)
                        
                        #render some response to the app 
                        render json: answers  

                        #create thread and deal with the new data that have been uploaded
                        Thread.new do 
                              answers.each do |row| 
                                    #things.push(row[0])
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
      		#The questionnaire 
      		@quest = Questionnaire.find(@id)

      		@categories = Category.where(questionnaire_id_id: @id).order(order: :asc)

      		#very important name is right yes no change or else break 
      		#trademark protected name yes 
      		@superArrayThatisAnObject = {
      			'questionnaire' => @quest, 
      			'categories' => [
                        ], 
      			'response_options' => {

      			}, 
      			'media_files' => {

      			}
      		}

      		for x in @categories do 
      			questionsForCategory = Question.where(category_id: x.id)
      			audioFileIDs = Question.where(category_id: x.id).uniq.pluck(:question_audio)
      			imageFileIDs = Question.where(category_id: x.id).uniq.pluck(:question_image)

      			responseOptionIDs = questionsForCategory.uniq.pluck(:response_id)
      			responseOptions = ResponseOption.where(id: responseOptionIDs)
      			
                        categoryAudioIDs = Category.where(id: x.id).uniq.pluck(:audio) 
                        categoryImageIDs = Category.where(id: x.id).uniq.pluck(:image) 
      			#To be added to the superArray 
      			respOptionsData = {
      			}

      			mediaFileIDs = audioFileIDs + imageFileIDs + categoryAudioIDs + categoryImageIDs
      			mediaFileIDs = mediaFileIDs.uniq 
				
				responseOptions.each do |opt|
      				@superArrayThatisAnObject['response_options'][opt.id] = {
      					'info' => opt, 
      					'response_items' => []
      				}
      				responseItems = ResponseOptionItem.where(response_option_id: opt.id)

      				@superArrayThatisAnObject['response_options'][opt.id]['response_items'] = responseItems.to_json
      				responseItemsIDs = responseItems.uniq.pluck(:audio)

      				mediaFileIDs = mediaFileIDs + responseItemsIDs 
      			end 

      			mediaFiles = MediaFile.where(id: mediaFileIDs)

      			mediaFiles.each do |media| 
      				@superArrayThatisAnObject['media_files'][media.id] = media
      			end 

      			@superArrayThatisAnObject['categories'].push(
      				'audio' => x.audio, 
      				'image' => x.image, 
      				'description' => x.description, 
      				'questions' => questionsForCategory, 
                              'id' => x.id
      			)
      		end 

      		render json: @superArrayThatisAnObject 
      	end 

            def fetchAllForUser
                  stuff = {
                        'things' => 'Hej'
                  }

                  response = Questionnaire.where(user_id: params[:id])

                  render json: response; 
            end 

            
	end 
end
