class TyphoeusCache

  def initialize(client = nil)
    @redis = client || Redis.new
  end

  def get(key)
    @redis.get key
  end

  def set(key, value)
    @redis.set key, value
  end

end