require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"


#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	erb :index
end

# displays all the parking listings
get "/parking" do
	@spots = Spot.all
	erb :parking
end


get "/parking/new" do
	authenticate!
	erb :new
end

# displays parking lost being listed by user
get '/parking/dashboard' do
	authenticate!
	@user_lots = current_user.spots
	erb :dashboard
end

# displays a single lot
get '/parking/:id' do
	@spot = Spot.get(params[:id].to_i)
	erb :lot
end

get "/parking/:id/rent" do
	authenticate!
	return "renting via stripe"
end



post "/parking/create" do
	authenticate!
	if params[:location] && params[:amount] && params[:cost]
		current_user.spots.create(
			:location => params[:location],
			:lots_available => params[:amount],
			:cost_per_lot => params[:cost]
		)
	end

	redirect "/parking"
end
