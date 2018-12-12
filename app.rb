require "sinatra"
require 'sinatra/flash'
require 'stripe'
require_relative "authentication.rb"

set :publishable_key, "pk_test_mCY7uTS4r29eFFS2hIgItZmV"
set :secret_key, "sk_test_8VBkxv3Jf0gcRLbYTCWGhPqD"

Stripe.api_key = settings.secret_key

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


get '/parking/dashboard/:id' do
	authenticate!
	@lot = Spot.get(params[:id].to_i)
	erb :manage
end

get '/parking/dashboard/:id/delete' do
	authenticate!
	@lot = Spot.get(params[:id].to_i)
	@lot.destroy
	redirect '/parking/dashboard'
end

get "/parking/rented" do
	authenticate!
	if current_user.is_renting_spot?
		@lots_rented = current_user.get_renting_spot
	end

	erb :rented
end

# displays a single lot
get "/parking/:id" do
	@spot = Spot.get(params[:id].to_i)
	erb :lot
end

get "/parking/:id/release" do
	authenticate!
	current_user.free_spot
	erb :rented
end

get '/parking/:id/rent' do
	authenticate!
	@id = params[:id].to_i
	@cost = Spot.get(@id).cost_per_lot
	erb :rent 
end
post '/parking/:id/rent' do
	authenticate!
	spot = Spot.get(params[:id].to_i)
	# Amount in cents
	dollars = spot.cost_per_lot.to_i;
	@amount = (dollars * 60).to_i + (spot.cost_per_lot - dollars).to_i
  
	customer = Stripe::Customer.create(
	  :email => 'customer@example.com',
	  :source  => params[:stripeToken]
	)
  
	charge = Stripe::Charge.create(
	  :amount      => @amount,
	  :description => 'Sinatra Charge',
	  :currency    => 'usd',
	  :customer    => customer.id
	)

	current_user.rent_spot(params[:id].to_i)
	redirect "/parking/rented"
  end


post "/parking/create" do
	authenticate!
	if params[:location] && params[:amount] && params[:cost]
		current_user.spots.create(
			:location => params[:location],
			:lots_available => params[:amount],
			:cost_per_lot => params[:cost])
	end

	redirect "/parking"
end
