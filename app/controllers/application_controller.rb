class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

  # stuff for handling authentication

  protected

  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers


    

    headers['Access-Control-Allow-Origin'] =  get_allowed_url request
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = '1728000'
    headers['Access-Control-Allow-Credentials'] = 'true'
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'

      headers['Access-Control-Allow-Origin'] = get_allowed_url request
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'
      headers['Access-Control-Allow-Credentials'] = 'true'

      render text: '', content_type: 'text/plain'
    end
  end

  def get_allowed_url(request)
    @origin = ''
    @req_origin = request.headers['origin']
    puts @req_origin.to_s
    if @req_origin
      if @req_origin.start_with?('http://localhost:4200')
        @origin = @req_origin
      elsif @req_origin.start_with?('http://127.0.0.1:4200')
        @origin = @req_origin
      end
    end
    puts @origin
    @origin
  end

  def authenticate_user
    if session[:user_id]
      # set the current user object to @current_user object
      @current_user = User.find session[:user_id]
      true
    else
      redirect_to(controller: 'sessions', action: 'login')
      false
    end
  end

  def save_login_state
    if session[:user_id]
      # redirect_to(:controller => 'sessions', :action => 'home')
      # redirect_to(controller: 'questionnaires', action: 'index')
      false
    else
      true
    end
  end
end
