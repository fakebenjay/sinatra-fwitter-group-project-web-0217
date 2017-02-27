require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    redirect "/tweets" if Helpers.is_logged_in?(session)
    erb :'/users/create_user'
  end

  post '/signup' do
    if params.values.any?{|v| v.empty?}
      redirect "/signup"
    end
    @user = User.create(params)
    @user.update(username: params[:username].downcase)
    session[:user_id] = @user.id
    redirect "/tweets"
  end

  get '/login' do
    redirect "/tweets" if Helpers.is_logged_in?(session)
    erb :'/users/login'
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect "/tweets"
    else
      redirect "/failure"
    end
  end

  get '/tweets' do
    redirect "/login" if !Helpers.is_logged_in?(session)
    @user = Helpers.current_user(session)
    @tweets = Tweet.all
    erb :'/tweets/tweets'
  end

  get '/logout' do
    session.clear
    redirect "/login"
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    @tweets = @user.tweets
    erb :'/tweets/tweets'
  end

  get '/tweets/new' do
    if Helpers.is_logged_in?(session)
      erb :'/tweets/create_tweet'
    else
      redirect "/login"
    end
  end

  post '/tweets' do
    if params[:content].empty?
      redirect "/tweets/new"
    else
      @tweet = Tweet.create(params)
      @user = Helpers.current_user(session)
      @user.tweets << @tweet
      redirect "/tweets"
    end
  end

  get '/tweets/:id' do
    if !Helpers.is_logged_in?(session)
      redirect "/login"
    else
      @tweet = Tweet.find(params[:id])
      erb :'/tweets/show_tweet'
    end
  end

  get '/tweets/:id/edit' do
    redirect "/login" if !Helpers.is_logged_in?(session)
    @tweet = Tweet.find(params[:id])
    @user = Helpers.current_user(session)
    if @tweet.user == @user
      erb :'/tweets/edit_tweet'
    else
      redirect "/tweets"
    end
  end

  post '/tweets/:id' do
    if params[:content].empty?
      redirect "/tweets/#{params[:id]}/edit"
    else
      @tweet = Tweet.find(params[:id])
      @tweet.update(content: params[:content])
      redirect "/tweets"
    end
  end

  post '/tweets/:id/delete' do
    redirect "/login" if !Helpers.is_logged_in?(session)
    @tweet = Tweet.find(params[:id])
    @user = Helpers.current_user(session)
    if @tweet.user == @user
      @tweet.delete
      redirect "/tweets"
    else
      redirect "/tweets"
    end
  end
end
