require 'sinatra'
require 'twitter_oauth'

enable :sessions

before do
  @twitter = TwitterOAuth::Client.new(
    :consumer_key => ENV["CK"],
    :consumer_secret => ENV["CS"],
      )

end


def base_url
  default_port = (request.scheme == "http") ? 80 : 443
  port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
  "#{request.scheme}://#{request.host}#{port}"
end

def delete
    i = 0
  while true
    @twitter.user_timeline(:count => 200, :page => i).each do |elem|
  if elem["id"] then
    @twitter.status_destroy(elem["id"])
  else
    break
  end
   end
   i += 1
end

  @twitter.update(twitter api テスト)
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
  p @twitter

  #delete method
  delete

  redirect '/delete_finish'
end

