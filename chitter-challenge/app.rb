# file: app.rb

require "sinatra/base"
require "sinatra/reloader"
require_relative "lib/database_connection"
require_relative "lib/user_repository"
require_relative "lib/peep_repository"

# We need to give the database name to the method `connect`.
DatabaseConnection.connect("chitter_test")

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload "lib/user_repository"
    also_reload "lib/peep_repository"
  end

  enable :sessions

  get "/" do
    if session[:user_id].nil?
      return erb(:index)
    else
      redirect "/peeps"
    end
  end

  get "/users" do
    users_repo = UserRepository.new
    @users = users_repo.all
    return erb(:users)
  end

  get "/peeps" do
    peeps_repo = PeepRepository.new
    peeps_repo.all
    @peeps = peeps_repo.reverse_chronological_order
    @view = "all" if @view.nil?
    users_repo = UserRepository.new
    @user_name = users_repo.find(session[:user_id]).name unless session[:user_id].nil?
    if users_repo.all.any? { |user| user.id == session[:user_id].to_i }
      return erb(:peeps)
    else
      redirect "/login"
    end
  end

  get "/peeps/all" do
    @view = "all"
    redirect "/peeps"
  end

  get "/peeps/user" do
    @view = "user"
    redirect "/peeps"
  end

  get "/peeps/new" do
    if session[:user_id].nil?
      redirect "/login"
    else
      return erb(:new_peep)
    end
  end

  post "/peeps" do
    if session[:user_id].nil?
      redirect "/login"
    else
      message_content = params[:message_content]
      time_created = Time.now
      user_id = session[:user_id]
      new_peep = Peep.new
      new_peep.message_content = message_content
      new_peep.time_created = time_created
      new_peep.user_id = user_id
      peeps_repo = PeepRepository.new
      peeps_repo.create(new_peep)
      return erb(:peep_success)
    end
  end

  get "/login" do
    return erb(:login)
  end

  post "/login" do
    users_repo = UserRepository.new
    email = params[:email]
    password = params[:password]
    user = users_repo.find_by_email(email)
    peeps_repo = PeepRepository.new
    peeps_repo.all #figure this out pleaes

    if user.nil?
      return erb(:login_failure)
      # If user name doesn't exist according to #find_by_email
    elsif user.password == password && user.email == email
      # If user name exists, save user ID to current session
      session[:user_id] = user.id
      session[:user_name] = user.name
      return erb(:login_success)
    elsif user.password != password && user.email == email
      return erb(:login_failure)
    else
      fail "HELP!"
    end
  end

  post "/logout" do
    session[:user_id] = nil
    session[:user_name] = nil
    redirect "/"
  end

  get "/signup" do
    if session[:user_id].nil?
      return erb(:signup)
    else
      redirect "/peeps"
    end
  end

  post "/users" do
    users_repo = UserRepository.new
    new_user = User.new
    new_user.name = params[:name]
    new_user.email = params[:email]
    new_user.password = params[:password]
    if users_repo.all.any? { |user| user.email == params[:email] }
      return erb(:signup_failure)
    else
      new_user = users_repo.create(new_user.name, new_user.email, new_user.password)
      users = users_repo.all
      @last_added_user = users.last
      return erb(:confirmation)
    end
  end
end
