
class Spot
    include DataMapper::Resource
    property :id, Serial
    property :location, String
    property :lots_available, Integer
    property :cost_per_lot, Float
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Spot.auto_upgrade!
