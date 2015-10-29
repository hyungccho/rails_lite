require 'webrick'
require_relative 'lib/controller_base'
require_relative 'lib/router'
require_relative 'lib/sql_object'
Dir["lib/controllers/*.rb"].each {|file| require_relative file }


# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

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

server = WEBrick::HTTPServer.new(Port: 80)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
