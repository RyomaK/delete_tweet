  require 'sinatra'
  require 'twitter_oauth'

  enable :sessions

  before do
    @twitter = TwitterOAuth::Client.new(
      :consumer_key => ENV["CK"]
      :consumer_secret => ENV["CS"]
      )


  end


  def base_url
    default_port = (request.scheme == "http") ? 80 : 443
    port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
    "#{request.scheme}://#{request.host}#{port}"
  end

  def delete
    begin
      k = 1
      isbreak = false
      while true do
        if (k % 150) != 0 then 
          @twitter.user_timeline(:count=>200).each do |elem|
           p elem["id_str"]
           if elem["id_str"] != nil   then
             @twitter.status_destroy(elem["id"])
           else
            isbreak = true 
            break
           end
          end
          k += 1
        else
          sleep (900)
        end
        break if isbreak
      end
    rescue Timeout::Error
      @twitter.update("apiの関係で15分後やり直してください")
  end

  @twitter.update("twitter api テスト")
  end

  get '/' do
    erb :delete
  end

  get '/delete_finish' do
    erb :delete_finish
  end

  get '/request_token' do
    callback_url = "#{base_url}/access_token"
    request_token = @twitter.request_token(:oauth_callback => callback_url)
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    redirect request_token.authorize_url
  end


  get '/access_token' do
    begin
      @access_token = @twitter.authorize(session[:request_token], session[:request_token_secret],:oauth_verifier => params[:oauth_verifier])
    rescue OAuth::Unauthorized => @exception
      return erb :authorize_fail
    end
    #access token
    session[:access_token] = @access_token.token
    session[:access_token_secret] = @access_token.secret

    #put
    p session[:access_token]
    p session[:access_token_secret]
    

    #delete method
    delete

    redirect '/delete_finish'
  end

