class UsersController < ApplicationController
  # create a new user
  def new
    @user = User.new

    all_users = User.all
    all_users.each do |user|
      logger.debug user.inspect
    end

    if authenticate_user
      @curr_user = User.find(session[:user_id])
      @username = @curr_user.username
    end

    redirect_to questionnaires_path unless @curr_user.create_user_permission
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash.now[:notice] = 'Konto skapat!'
    else
      flash.now[:notice] = 'Ett fel uppstod.'
    end

    if authenticate_user
      @curr_user = User.find(session[:user_id])
      @username = @curr_user.username
    end

    render new_user_path
  end

  # before_filter :save_login_state, :only => [:new, :create]

  private

  # definierar vilka parametrar som är tillåtna för question
  def user_params
    params.require(:user).permit(
      :username, :password, :email, :create_user_permission,
      :create_questionnaire_permission)
  end
end
