class ResponseOptionsController < ApplicationController
  protect_from_forgery with: :null_session,
                       if: proc { |c| c.request.format == 'application/json' }
  respond_to :json, :xml, :html, :js

  def index
  end

  def new
    # ResponseOption.new
    response_option = ResponseOption.new
    response_option.name = 'Ny uppsättning'
    response_option.availability = false

    response_option.save

    render json: { 'status' => 'created', 'id' => response_option.id }
  end

  def create
    response_option = ResponseOption.new
    response_option.name = 'Ny uppsättning'
    response_option.availability = false
    response_option.question_id = params[:question_id]
    response_option.questionnaire_id = params[:questionnaire_id]

    response_option.save

    render json: { 'status' => 'created', 'id' => response_option.id }

    # #the JSON that will be stored for the response option
    # resp_json = []
    #
    # resp_vals = params[:respVal]
    # resp_label = params[:respLbl]
    # resp_vals.zip(resp_label) do |v, l|
    # 	obj = {
    # 		'val' => v,
    # 		'label' => l
    # 	}
    # 	resp_json.push(obj)
    # end
    #
    # @res = ResponseOption.new(resp_params)
    # @res.options = resp_json.to_json
    # @res.save
    #
    # render plain: resp_json.inspect
  end

  # Main method for editing response options
  def edit
    resp_json = []

    set_id = params[:response_option_id]
    set_name = params[:response_option_name]
    set_availability = params[:response_option_availability] ? true : false
    resp_vals = params[:respVal] || []
    resp_label = params[:respLbl]
    resp_audio = params[:respAudio]
    item_ids = params[:respValItemId]

    response_option_set = ResponseOption.find(set_id)
    response_option_set.name = set_name
    response_option_set.availability = set_availability

    response_option_set.save

    # When the set is saved move on to the rest stuff
    resp_vals.each_with_index do |resp_val, i|
      id = item_ids[i]
      if ResponseOptionItem.find(id)
        response_option_item = ResponseOptionItem.find(item_ids[i])
        response_option_item.label = resp_label[i]
        response_option_item.value = resp_val

        if resp_audio[i] != ''
          # upload the audio file
          item_audio = resp_audio[i]

          if item_audio.original_filename
            filename = Rails.root.join('public', 'uploads',
                                       item_audio.original_filename)

            File.open(filename, 'wb') do |file|
              file.write(item_audio.read)
              @media_path = File.basename(file.path) # file.path

              # save details about the image in media_files
              now_time = Time.now.to_i
              audio_file_name = "option_audio_#{now_time}_#{item_audio.original_filename}"
              # audio_file_name = 'option_audio_' + now_time.to_s + File.extname(file)

              # rename the uploaded file
              new_file_name = Rails.root.join('public', 'uploads', audio_file_name)
              File.rename(file, new_file_name)

              @media_files = MediaFile.create(
                media_type: 'audio',
                ref: audio_file_name
              )
              @media_files.save
              # get the id of the inserted mediafile
              @audio_id = MediaFile.last.id
              # save the img to the item
              response_option_item.audio = @audio_id
            end
          end
        end
      end

      # save
      response_option_item.save
    end
    render plain: params
  end

  def destroy
    response_option_items = ResponseOptionItem.where(response_option_id: params[:id])

    destroyed_id = []
    response_option_items.each do |opt|
      response_item = ResponseOptionItem.find(opt.id)
      response_item.destroy

      destroyed_id.push(opt.id)
    end
    resp_opt_set = ResponseOption.find(params[:id])
    resp_opt_set.destroy

    questions_with_deleted_option = Question.where(response_id: params[:id])

    questions_with_deleted_option.each do |question|
      question.response_id = nil

      question.save
    end

    render json: destroyed_id
  end

  def list
    @response_options = ResponseOption.visible_response_options(session[:user_id])

    response_options_json = @response_options.map do |r|
      { id: r.id,
        name: r.name,
        availability: r.availability,
        question_id: r.question_id,
        used_by: Question.where(response_id: r.id).map(&:id).uniq }
    end

    render json: response_options_json
  end

  def by_id
    @id = params[:id]

    @resp_data = ResponseOption.find(@id)
    @options = ResponseOptionItem.where(response_option_id: @id)

    @response_data = {
      'id' => @resp_data.id,
      'name' => @resp_data.name,
      'availability' => @resp_data.availability,
      'question_id' => @resp_data.question_id,
      'options' => @options.to_json
    }

    render json: @response_data
  end

  def audio_by_id
    id = params[:id]

    option = ResponseOptionItem.find(id)
    audio_file = option.audio ? MediaFile.find(option.audio) : ''

    render json: audio_file
  end

  def add_response_option_item
    # the id of the response_options set
    @resp_opt_id = params[:id]
    # create a new response_option_item for that set
    @item = ResponseOptionItem.new
    @item.response_option_id = @resp_opt_id
    @item.save

    render json: @item
  end

  def delete_response_option_item
    id = params[:id]

    if ResponseOptionItem.destroy(id)
      render json: { 'status' => 'success', 'item_id' => id }
    else
      render json: { 'status' => 'fail', 'item_id' => id }
    end
  end

  private

  # definierar vilka parametrar som är tillåtna för response_option
  def resp_params
    params.require(:response_option).permit(
      :name, :availability, :question_id, :opts, :respVal, :respLbl)
  end
end
