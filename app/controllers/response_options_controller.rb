class ResponseOptionsController < ApplicationController
	protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
	respond_to :json, :xml, :html, :js


	def index

	end

	def new
		#ResponseOption.new
		responseoption = ResponseOption.new
		responseoption.name = "Ny uppsättning"

		responseoption.save


		render json: {'status' => 'created', 'id' => responseoption.id}
	end

	def create
		#the JSON that will be stored for the response option
		respJSON = []

		respVals = params[:respVal]
		respLbl = params[:respLbl]
		respVals.zip(respLbl) do |v, l|
			obj = {
				'val' => v,
				'label' => l
			}
			respJSON.push(obj)
		end

		@res = ResponseOption.new(resp_params)
		@res.options = respJSON.to_json
		@res.save

		render plain: respJSON.inspect
	end

	#Main method for editing response options
	def edit
		respJSON = []

		setId = params[:response_option_id]
		setName = params[:response_option_name]
		respVals = params[:respVal]
		respLbl = params[:respLbl]
		respAudio = params[:respAudio]
		itemIDs = params[:respValItemId]

		respOptionSet = ResponseOption.find(setId)
		respOptionSet.name = setName

		respOptionSet.save

		#When the set is saved move on to the rest stuff
		i = 0
		len = respVals.length
		#testArr = []
		while (i < len) do
			id = itemIDs[i]
			if(ResponseOptionItem.find(id))
				#testArr.push(id)
				respOptItem = ResponseOptionItem.find(itemIDs[i])
				respOptItem.label = respLbl[i]
				respOptItem.value = respVals[i]
				if respAudio[i] != ""
					#upload the audio file
					itemAudio = respAudio[i]
					if itemAudio.original_filename
						File.open(Rails.root.join('public', 'uploads',
						itemAudio.original_filename), 'wb') do |file|
							file.write(itemAudio.read)
							@media_path = File.basename(file.path) #file.path
							#render text: @media_path
							@mfiles = MediaFile.create(
								media_type: 'audio',
								ref: @media_path
							)
							@mfiles.save
							#get the id of the inserted mediafile
							@audid = MediaFile.last.id
							#save the img to the item
							respOptItem.audio = @audid
						end
					else
					end
				else
					#maybe do something here?
				end
			else
				#testArr.push("Other")
			end
			#save
			respOptItem.save
			#update i
			i = i + 1
		end
		render plain: params
	end

	def destroy

		responseOptionItems = ResponseOptionItem.where(response_option_id: params[:id])

		destroyedId = []
		responseOptionItems.each do |opt|
			responseItem = ResponseOptionItem.find(opt.id)
			responseItem.destroy

			destroyedId.push(opt.id)
		end
		respOptSet = ResponseOption.find(params[:id])
		respOptSet.destroy

		questionsWithDeletedOption = Question.where(response_id: params[:id])

		questionsWithDeletedOption.each do |question|
			question.response_id = nil

			question.save
		end

		render json: destroyedId
	end

	def list
		@response_options = ResponseOption.all
		render json: @response_options
	end

	def getById
		@id = params[:id]

		@respData = ResponseOption.find(@id)
		@options = ResponseOptionItem.where(response_option_id: @id)

		@responseData = {
			'id' => @respData.id,
			'name' => @respData.name,
			'options' => @options.to_json
		};

		render json: @responseData
	end

	def addResponseOptionItem
		#the id of the response_options set
		@roID = params[:id]
		#create a new response_option_item for that set
		@item = ResponseOptionItem.new
		@item.response_option_id = @roID
		@item.save

		render json: @item
	end

	def deleteResponseOptionItem
		id = params[:id]

		if ResponseOptionItem.destroy(id)
			render json: {'status' => 'success', 'item_id' => id}
		else
			render json: {'status' => 'fail', 'item_id' => id}
		end
	end

	private
		#definierar vilka parametrar som är tillåtna för response_option
		def resp_params
			params.require(:response_option).permit(:name, :opts, :respVal, :respLbl)
		end
end
