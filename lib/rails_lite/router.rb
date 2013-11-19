class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    if (req.request_method.downcase.to_sym == http_method)
      return true unless pattern.match(req.path).nil?
    end

    false
  end

  def run(req, res)
    match_data = pattern.match(req.path)
    controller = controller_class.new(req, res, route_params(match_data))
    controller.invoke_action(action_name)
  end

  def route_params(match_data)
    route_params = {}
    captures = match_data.captures
    match_data.names.each_with_index do |name, idx|
      capture = captures[idx]
      route_params[name.to_sym] = capture
    end

    route_params
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    self.routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action|
      add_route(pattern, http_method, controller_class, action)
    end
  end

  def match(req)
    routes.each do |route|
      return route if route.matches?(req)
    end

    nil
  end

  def run(req, res)
    route = match(req)
    if (route)
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
