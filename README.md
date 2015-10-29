#Rails Lite

##Active Record Lite

Unveils the 'magic' behind Active Record using Ruby's metaprogramming capabilities. Active Record was part one of re-building Rails, and it involved a deeper understanding of the Ruby language.

````ruby
class SQLObject
  extend Associatable
  extend Searchable

  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @columns = cols.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end

      define_method("#{col}") do
        self.attributes[col]
      end
    end
  end

  ...
````

By using modules, Ruby's own `define_method`, the project simulates the behaviors of Active Record. I also used `WEBrick` to connect to my local server using `mount_proc`.

````ruby
server = WEBrick::HTTPServer.new(Port: 80)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end
````

Once the connection is established and a request is sent to the WEBrick server, it sends the user to the appropriate route using a custom `Router` that I built.

````ruby
router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  get Regexp.new("^/cats/(?<cat_id>\\d+)/edit/$"), CatsController, :edit
  get Regexp.new("^/cats/(?<cat_id>\\d+)/$"), CatsController, :show
  put Regexp.new("^/cats/(?<cat_id>\\d+)/$"), CatsController, :update
  delete Regexp.new("^/cats/(?<cat_id>\\d+)/$"), CatsController, :destroy
end
````

This creates the RESTful routes and receives a request and sends it the appropriate controller method if it finds a match:

````ruby
class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @method = http_method
    @controller = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    (@method == req.request_method.downcase.to_sym) && !!(@pattern =~ req.path)
  end
  ...
````

My `ControllerBase` receives this request which also has the functionality of CSRF protection, and `Flash` to render content to the user.

````ruby
...
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
...
````

#Running on Local Server

Clone the project and inside the project root, run rails: `$ rails s`. This will create a WEBrick connection on port `80`. You can navigate to it by typing in `localhost:80` (if on OSX).

Edit the pages to your heart's desire. By default, you can check to see if it's working by navigating to `localhost:80/cats`. If you see a list of weird cat names, you're all set!
