class SessionsController < ApplicationController
  def login
    # sends to login.erb.html
  end

  # def for the auth method
  def login_attempt
    authorized_user = User.authenticate(params[:username_or_email],
                                        params[:login_password])

    if authorized_user
      session[:user_id] = authorized_user.id
      flash[:notice] = "Välkommen åter, #{authorized_user.username}."
      # redirect_to(:action => 'home')
      redirect_to(controller: 'questionnaires', action: 'index')
    else
      flash[:notice] = 'Felaktigt användarnamn eller lösenord.'
      flash[:color] = 'invalid'
      render 'login'
    end

    # redirect_to(:controller => 'sessions', :action => 'home')
    # return false
  end

  # logout
  def logout
    session[:user_id] = nil
    flash[:notice] = ''
    redirect_to action: 'login'
  end

  def home
  end

  def show
    @questionnaires = Questionnaire.all
  end

  def profile
  end

  def setting
  end

  before_action :authenticate_user, only: [:home, :profile, :setting]
  before_action :save_login_state, only: [:login, :login_attempt]
end
