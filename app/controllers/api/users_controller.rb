module Api
	class UsersController < ApplicationController
		protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
		respond_to :json, :xml, :html, :js

		def index
			render plain: "Fuck it "
		end

		def login
			@username = params[:username]
			@login_password = params[:password]

			authorized_user = User.authenticate(@username, @login_password)

		  	if authorized_user
		  		@info =	User.find(authorized_user.id)
		  		render json: @info
		  	else
		  		resp = {
		  			'loginFail' => true
		  		}
		  		render json: resp
		  	end

			#render plain: @username
		end
	end

end
