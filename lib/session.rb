require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @value = {}

    req.cookies.each do |cook|
      name = cook.name
      if name == "_rails_lite_app"
        @value = JSON.parse(cook.value)
        break
      end
    end
  end

  def [](key)
    @value[key.to_s]
  end

  def []=(key, val)
    @value[key.to_s] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    new_cookie = WEBrick::Cookie.new("_rails_lite_app", @value.to_json)
    res.cookies << new_cookie
  end
end
