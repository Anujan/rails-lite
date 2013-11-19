require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params={})
    @request = req
    @response = res
    @params = Params.new(req, route_params)
  end

  def controller_name
    self.class.to_s.underscore
  end

  def render_content(body, content_type)
    @response.content_type = content_type
    @response.body = body
    finish_response
  end

  def redirect_to(url)
    @response.header['Location'] = url
    @response.status = 302
    finish_response
  end

  def finish_response
    @already_built_response = true
    session.store_session(@response)
  end

  def session
    @session ||= Session.new(@request)
  end

  def already_rendered?
    !!@already_built_response
  end

  def render(template_name)
    contents = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb = ERB.new(contents)
    result = erb.result(binding)

    render_content(result, 'text/html')
  end

  def invoke_action(name)
    self.send(name)
  end
end
