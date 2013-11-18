require 'json'
require 'webrick'

class Session
  DEFAULT_COOKIE_NAME = '_rails_lite_app'

  def initialize(req)
    @session_cookie = {}
    req.cookies.each do |cookie|
      if cookie.name == DEFAULT_COOKIE_NAME
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

  def store_session(res)
    res.cookies << WEBrick::Cookie.new(DEFAULT_COOKIE_NAME, JSON.dump(@session_cookie))
  end
end
