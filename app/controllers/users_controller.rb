class UsersController < ApplicationController
	#create a new user 
	def new
		@user = User.new
	end

	def create 
		@user = User.new(user_params)
		#render plain: @user.inspect
		if @user.save 
			flash[:notice] = "Konto skapat!"
			flash[:color] = "valid"
		else  
			flash[:notice] = "Ett fel uppstod"
			flash[:color] = "invalid"
		end 

		render 'new'
	end 

	before_filter :save_login_state, :only => [:new, :create]
	
	private 
		#definierar vilka parametrar som är tillåtna för question
		def user_params 
			params.require(:user).permit(:username, :password, :email, :role, :Signup)
		end
end
