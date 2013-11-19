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
    session.store(@response)
    flash.store(@response)
  end

  def session
    @session ||= Session.new(@request)
  end

  def flash
    @flash ||= Flash.new(@request)
  end

  def already_rendered?
    !!@already_built_response
  end

  def form_authenticity_token
    @form_authenticity_token ||= SecureRandom.base64(32)
    session[:csrf] = @form_authenticity_token
  end

  def verify_csrf
    if session[:csrf].nil? || session[:csrf] != params[:authenticity_token]
      session.clear
    end
  end

  def render(template_name)
    contents = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb = ERB.new(contents)
    result = erb.result(binding)

    render_content(result, 'text/html')
  end

  def invoke_action(name)
    self.send(name)
    unless already_rendered?
      render(name)
    end
  end
end
