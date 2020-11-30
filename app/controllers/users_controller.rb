class UsersController < ApplicationController
  # skip_before_action :require_login
  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid], provider: params[:provider])

    if user
      flash[:notice] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:notice] = "Logged in as new user #{user.username}"
      else
        #flash[:error] = "Could not create new user account #{user.errors.messages}"
        flash[:error] =  ["Could not create new user account username: #{user.errors.messages[:username]}"]
      end

    end
    session[:user_id] = user.id
    redirect_to root_path
  end


  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  # def login_form
  # end
  #
  # def login
  #   auth_hash = request.env["omniauth.auth"]
  #   user = User.find_by(uid: auth_hash[:uid], provider: 'github')#params[:provider])
  #   username = user.username
  #   #username = params[:username]
  #   # if username and user = User.find_by(username: username)
  #   if username
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end

  def logout
      if session[:user_id]
        session[:user_id] = nil
        flash[:notice] = "Successfully logged out"
        redirect_to root_path
        return
      else
        flash[:warning] = "You were not logged in!"
        redirect_to root_path
      end
  end

end