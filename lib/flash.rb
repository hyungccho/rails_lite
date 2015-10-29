class Flash

  attr_reader :flash, :flash_now

  def initialize(req)
    @flash = {}
    @flash_now = {}

    req.cookies.each do |cook|
      name = cook.name
      if name == "flash"
        @flash = JSON.parse(cook.value)
        break
      end
    end
  end

  def []=(key, value)
    @flash[key] = value
  end

  def [](key)
    @flash[key]
  end

  def now
    @flash_now
  end

  def store_flash
    new_cookie = WEBrick::Cookie.new("flash", @flash)
    res.cookies << new_cookie
  end
end
