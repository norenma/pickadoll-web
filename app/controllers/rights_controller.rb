class RightsController < ApplicationController
  before_action :set_right, only: [:show, :edit, :update, :destroy]

  # GET /rights
  # GET /rights.json
  def index
    @rights = Right.all
  end

  # GET /rights/1
  # GET /rights/1.json
  def show
  end

  # GET /rights/new
  def new
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @curr_user = User.find(session[:user_id])
    @active_user_right = Right.find_by(questionnaire_id: @questionnaire.id,
                                       subject_id: @curr_user.id)

    @right = Right.new
  end

  # GET /rights/1/edit
  def edit
  end

  # POST /rights
  # POST /rights.json
  def create
    # Find subject user
    subject = User.by_username_or_email(params[:username_or_email])

    if subject
      questionnaire_id = params[:questionnaire_id]
      user_id = session[:user_id]
      subject_id = subject.id

      # Find existing right, if it exists
      @right = Right.find_by(questionnaire_id: questionnaire_id,
                             user_id: user_id, subject_id: subject_id)

      # Find active user's right for questionnaire, if it exists
      active_user_right = Right.find_by(questionnaire_id: questionnaire_id,
                                        subject_id: user_id)

      new_right_level = params[:write_permission] ? :rw : :r
      new_right_level = :r if active_user_right && active_user_right.level == :r
      new_right_level = :rw if @right && @right.level == :rw

      @right ||= Right.new
      @right.level = new_right_level
      @right.questionnaire_id = questionnaire_id
      @right.user_id = user_id
      @right.subject_id = subject_id

      if @right.save
        flash[:notice] = "Enkäten har delats med #{subject.username}!"
      else
        flash[:notice] = 'Ett fel uppstod.'
      end
    else
      flash[:notice] = 'Användaren kunde inte hittas.'
    end

    # respond_to do |format|
    #   if @right.save
    #     puts "Saved right: #{@right.inspect}"
    #     format.html { render new_questionnaire_right_path(params[:questionnaire_id]), notice: 'Enkäten har delats!' }
    #     # format.json { render :show, status: :created, location: @right }
    #   else
    #     format.html { render :new, notice: 'Ett fel uppstod.' }
    #     # format.json { render json: @right.errors, status: :unprocessable_entity }
    #   end
    # end

    redirect_to new_questionnaire_right_path(params[:questionnaire_id])
  end

  # PATCH/PUT /rights/1
  # PATCH/PUT /rights/1.json
  def update
    respond_to do |format|
      if @right.update(right_params)
        format.html { redirect_to @right, notice: 'Right was successfully updated.' }
        format.json { render :show, status: :ok, location: @right }
      else
        format.html { render :edit }
        format.json { render json: @right.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rights/1
  # DELETE /rights/1.json
  def destroy
    @right.destroy
    respond_to do |format|
      format.html { redirect_to rights_url, notice: 'Right was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_right
    @right = Right.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def right_params
    params[:right]
  end
end
