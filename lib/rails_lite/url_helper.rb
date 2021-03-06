module UrlHelper
  def define_url_helper(route)
    url = path_for_route(route)
    ControllerBase.send('define_method', name_for_route(route)) do |*obj|
      url.gsub(":id", obj.first.id)
    end
  end

  def add_link_helpers
    ControllerBase.send('define_method', 'link_to') do |label, url|
      "<a href=\"#{url}\">#{label}</a>"
    end

    ControllerBase.send('define_method', 'button_to') do |label, url|
      "<form method=\"post\" action=\"#{url}\" class=\"button_to\">
        <div><input value=\"#{label}\" type=\"submit\" /></div>
      </form>"
    end
  end

  def name_for_route(route)
    path = route.controller_name.downcase.singularize.gsub("controller", "")
    case route.action_name
    when :new
      "new_#{path}_url"
    when :edit
      "edit_#{path}_url"
    when :show
    when :update
    when :destroy
      "#{path}_url"
    when :index
      "#{path.pluralize}_url"
    else
      "##{path}_#{action_name}_url"
    end
  end

  def path_for_route(route)
    path = route.controller_name.downcase.gsub("controller", "")
    case route.action_name
    when :new
      path += '/new'
    when :edit
      path +=  '/:id/edit'
    when :show
    when :update
    when :destroy
      path += '/:id'
    when :index
      path
    else
      path += route.action_name.to_s
    end
  end
end