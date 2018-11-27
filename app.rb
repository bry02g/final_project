require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "spot.rb"

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


get "/dashboard" do
	authenticate!
	erb :dashboard
end

get "/parking" do
	@spots = Spot.all
	erb :parking
end

get "/parking/new" do
	erb :new
end

get "/parking/:id" do
	if params[:id]
		@spot = Spot.get(params[:id].to_i)
		erb :lot
	end
end

get "/parking/:id/rent" do
end



post "/parking/create" do
	if params[:location] && params[:amount] && params[:cost]
		spot = Spot.new
		spot.location = params[:location]
		spot.lots_available = params[:amount]
		spot.cost_per_lot = params[:cost]
		spot.save
	end

	redirect "/parking"
end
