require 'json'
require 'webrick'

class RailsLiteCookie
  def initialize(req)
    @session_cookie = {}
    req.cookies.each do |cookie|
      if cookie.name == cookie_name
        @session_cookie = JSON.parse(cookie.value)
      end
    end
  end

  def [](key)
    @session_cookie[key]
  end

  def []=(key, val)
    @session_cookie[key] = val
  end

  def store(res)
    res.cookies << WEBrick::Cookie.new(cookie_name, JSON.dump(@session_cookie))
  end

  def cookie_name
    "rails_lite_#{self.class.to_s.underscore}"
  end

  def clear
    @session_cookie.clear
  end
end


class Session < RailsLiteCookie
  def initialize(req)
    super(req)
  end
end

class Flash < RailsLiteCookie
  def initialize(req)
    super(req)
    @next_flash = {}
  end

  def []=(key, val)
    @next_flash[key] = val
  end

  def store(res)
    res.cookies << WEBrick::Cookie.new(cookie_name, JSON.dump(@next_flash))
  end
end