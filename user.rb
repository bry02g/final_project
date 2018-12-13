require 'data_mapper' # metagem, requires common plugins too.

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

class User
    include DataMapper::Resource
    property :id, Serial
    property :email, String
    property :password, String
    property :created_at, DateTime
    property :renting_spot_id, Integer , :default => 0
    has n, :spots

    def login(password)
    	return self.password == password
    end

    def is_renting_spot?
      if renting_spot_id == nil || renting_spot_id == 0
        return false
      else
        return true
      end
    end

    def get_renting_spot
      Spot.get(self.renting_spot_id)
    end

    def free_spot
      spot = Spot.get(self.renting_spot_id)
      spot.lots_available = spot.lots_available + 1
      spot.save
      self.renting_spot_id = 0
      self.save
    end

    def rent_spot(id)
      self.renting_spot_id = id
      spot = Spot.get(id)
    	spot.lots_available = spot.lots_available - 1
    	spot.save
    	self.save
    end
end

class Spot
    include DataMapper::Resource
    property :id, Serial
    property :location, String
    property :address, String
    property :lots_available, Integer
    property :cost_per_lot, Float

    belongs_to :user
end
# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
User.auto_upgrade!
Spot.auto_upgrade!
