require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require_relative 'session'
require_relative 'params'
require_relative 'flash'
require_relative 'application_controller'

class ControllerBase < ApplicationController
  attr_reader :req, :res

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = res
    @res = res
    @already_build_response = false
    @params = Params.new(req, route_params)
    @flash = Flash.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_build_response
  end

  # Set the response status code and header
  def redirect_to(url)
    res.status = 302
    res['location'] = url

    raise if already_built_response?
    @already_build_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    res.body = content
    res.content_type = content_type

    raise if already_built_response?
    @already_build_response = true
    session.store_session(res)
  end

  def render(template_name)
    file = File.read("lib/views/#{self.class.to_s.sub("Controller", "")}/#{template_name}.html.erb")
    template = ERB.new(file)
    request_body = template.result(binding)

    render_content(request_body, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  def invoke_action(name)
    if req.request_method = :GET
      new_cookie = WEBrick::Cookie.new("auth_token", form_authenticity_token)
      res.cookies << new_cookie
    else
      raise if req.cookies["auth_token"] != @params['authenticity_token']
    end
    # store_auth_token if is_get_request?
    # raise_CSRF unless csrf_matches?

    self.send("#{name}")

    render(name) unless self.already_built_response?
  end

  def flash
    @flash
  end
end
