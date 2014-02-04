# New York, New York.
(ridiculously) small and powerful micro web framework.

[![Build Status](https://api.travis-ci.org/alisnic/nyny.png)](https://travis-ci.org/alisnic/nyny)
[![Coverage Status](https://coveralls.io/repos/alisnic/nyny/badge.png)](https://coveralls.io/r/alisnic/nyny)
[![Code Climate](https://codeclimate.com/repos/521b7ee513d637348712864a/badges/60e3637788bbac94f1cb/gpa.png)](https://codeclimate.com/repos/521b7ee513d637348712864a/feed)
[![Gem Version](https://badge.fury.io/rb/nyny.png)](http://badge.fury.io/rb/nyny)

```ruby
# myapp.rb

require 'nyny'
class App < NYNY::App
  get '/' do
    'Hello world!'
  end
end

App.run!
```

Install the gem:

```bash
gem install nyny
```

Run the file:

```bash
ruby myapp.rb
```

Open the browser at [http://localhost:9292](http://localhost:9292)

- [TOP](#new-york-new-york)
- [Motivation](#motivation)
- [Philosophy](#philosophy)
- [Why use NYNY instead of Sinatra](#why-use-nyny-instead-of-sinatra)
- [Usage](#usage)
    - [Environment](#environment)
    - [Configuration](#configuration)
    - [Running](#running)
    - [Defining routes](#defining-routes)
    - [Request scope](#request-scope)
    - [Namespaces](#namespaces)
    - [Templates](#templates)
    - [Filters](#filters)
    - [Middleware](#middleware)
    - [Helpers](#helpers)
    - [Extensions](#extensions)
- [FAQ](#f-a-q)
- [Contributing](#contributing)

# Philosophy
NYNY is unassuming, it has all the core stuff to get running, but nothing else.
Your app is the framework. However, it's trivial to extend NYNY via its
[extension interface](#extensions).

# Why use NYNY instead of any other small web framework
- It's __very__ small (~300 LOC), which is just a little overhead on top of Rack.
- You want to dig into the source code and change to your needs (NYNY's source code is more welcoming)
- Each NYNY app is a Rack middleware, so it can be used inside of Sinatra, Rails, or any other Rack-based app.
- __It uses Journey for routing (Rails' router)__, which makes its routing logic
  a lot more powerful and reliable that in most micro web frameworks.

# Usage

A NYNY app must _always_ be in a class which inherits from `NYNY::App`:

```ruby
class App < NYNY::App
  get '/' do
    'Hello, World'
  end
end
```

## Environment
To get the directory in which your app is running use `NYNY.root`

```ruby
#/some/folder/server.rb
require 'nyny'
puts NYNY.root #=> /some/folder/
puts NYNY.root.join("foo") #=> /some/folder/foo
```

To get NYNY's environment, use `NYNY.env`

```ruby
#env.rb
require 'nyny'
puts NYNY.env
puts NYNY.env.production?
```

```bash
$ ruby env.rb
development
false

$ ruby env.rb RACK_ENV=production
production
true
```

## Configuration
You can configure your app by attaching arbitrary properties to config object:
```ruby
class App << NYNY::App
  config.foo = 'bar'
end

App.config.foo #=> 'bar'
```

Or, you can use the configure block:

```ruby
class App < NYNY::App
  configure do
    config.always = true
  end

  configure :production do
    config.prod = true
  end

  configure :test, :development do
    config.unsafe = true
  end
end
```

Also, NYNY provides a simple api for hooking into the app's initialization:
```ruby
class App < NYNY::App
  before_initialize do |app|
    #this will be executed just before the Rack app is compiled
    #'app' is the a App instance
  end

  after_initialize do |app, rack_app|
    #this will be executed after the Rack app is compiled
    #'app' is the a App instance
    #'rack_app' is the main block which will be called on any request
  end
end
```

## Running
There are two ways to run a NYNY app __directly__ [[?]](#middleware):

- by requiring it in a `config.ru` file, and then passing it as argument to the
Rack's `run` function:

```ruby
# config.ru

require 'app'
run App.new
```
- by using the `run!` method directly on the app class:

```ruby
# app.rb

# ...app class definition...

App.run!
```

`run!` takes the port number as optional argument (the default port is 9292).
Also the `run!` method will include 2 default middlewares to make the
development easier: Rack::CommonLogger and BetterErrors::Middleware (only in dev).
This will show all requests in the log, and will provide useful details
in the case a error occurs during a request.

## Defining routes

NYNY uses [Journey][journey] for routing, that means that NYNY has all the
awesomeness the Rails' router has. NYNY supports the following verbs for defining a route: delete, get, head,
options, patch, post, put and trace.

```ruby
class App < NYNY::App
  post '/' do
    'You Posted, dude!'
  end
end
```
You can use any construct or convention [supported in Rails][bound-params]
for the path string.

Each route definition call optionally accepts constraints:

```ruby
class App < NYNY::App
  get '/', :constraints => {:format => :html} do
    'html'
  end
end
```
You can use [the same constraints][constraints] you use in Rails.

Besides the constraints, you can specify defaults:
```ruby
class App < NYNY::App
  get '/', :defaults => {:format => 'html'} do
    'html'
  end
end
```

Each block that is passed to a route definition is evaluated in the context of
a request scope. See below what methods are available there.

## Request scope
As was said above, when you pass a block to a route definition,
that block is evaluated in the context of a [RequestScope][2].
This means that several methods/objects available inside that block:

- `request` - A `Rack::Request` object which encapsulates the request
  to that route. (see [Rack::Request documentation][3] for more info)
- `response` - A `Rack::Response` object which encapsulates the response.
  Additionally, NYNY's response exposes 2 more methods in addition to Rack's ones.
  (see [primitives.rb][primitivesrb])
- `params` - a hash which contains both POST body params and GET querystring params.
- `headers` - a hash with the response headers
  (ex: `headers['Content-Type'] = 'text/html'`)
- `status` - allows you to set the status of the response (ex: `status 403`)
- `redirect_to` - sets the response to redirect
  (ex: `redirect_to 'http://google.com'`)
- `cookies` - a hash which allows you to access/modify/remove cookies
  (ex: `cookies[:foo] = 'bar'` or `cookies.delete[:foo]`)
- `session` - a hash which allows you to access/modify/remove session variables
  (ex: `session[:foo] = 'bar'`)
- `halt` - allows you to instantly return a response, interrupting current
  handler execution (see [halt][halt-definition])


## Namespaces
You can define namespaces for routes in NYNY. Each namespace is an isolated
app, which means that you can use the same api that you use in your top app there:

```ruby
class App < NYNY::App
  get '/' do
    'Hello'
  end

  namespace '/nested' do
    use SomeMiddleware
    helpers SomeHelpers

    get '/' do # this will be accessible at '/nested'
      'Hello from namespace!'
    end
  end
end
```

## Templates
NYNY can render templates, all you need is to call the `render` function:
```ruby
class App < NYNY::App
  get '/' do
    render 'index.erb'
  end
end
```

There are 2 ways to pass data to the template:

Via a instance variable:
```ruby
class App < NYNY::App
  get '/' do
    @foo = 'bar' #access it as @foo in template
    render 'index.erb'
  end
end
```

Or via a local variable:
```ruby
class App < NYNY::App
  get '/' do
    render 'index.erb', :foo => 'bar' #access it as foo in template
  end
end
```

To render a template with a layout, you need to render both files. It's best
to create a helper for that:
```ruby
class App < NYNY::App
  helpers do
    def template *args
      render 'layout.erb' do
        render *args
      end
    end
  end

  get '/' do
    template 'index.erb'
  end
end
```
NYNY uses [Tilt][tilt] for templating, so the list of supported engines is pretty complete.

## Filters

Unlike Sinatra, NYNY supports only "generic" before and after filters.
This means that you can't declare a filter to execute depending on a URL pattern.
However, you can obtain the same effect by calling next in a before block
if the request.path matches a pattern.

```ruby
class App < NYNY::App
  before do
    next unless /html/ =~ request.path
    headers['Content-Type'] = 'text/html'
  end

  after do
    puts response.inspect
  end

  get '/' do
    'hello'
  end
end
```

## Middleware

A NYNY app is a Rack middleware, which means that it can be used inside
Sinatra, Rails, or any other Rack-based app:

```ruby
class MyApp < Sinatra::Base
  use MyNYNYApp
end
```

NYNY also supports middleware itself, and that means you can use Rack middleware
(or a Sinatra app) inside a NYNY app:

```ruby
class App < NYNY::App
  # this will serve all the files in the "public" folder
  use Rack::Static :url => ['public']
  use SinatraApp
end
```

I recommend looking at [the list of Rack middlewares][rack-middleware]

## Helpers

NYNY supports helpers as Sinatra does:

```ruby
class App < NYNY::App
  helpers MyHelperModule
  helpers do
    def using_a_block_to_define_helper
      true
    end
  end
end
```


Using a helper implies that the helper module is included in the [RequestScope][2],
and that all the methods in that module will be available inside a route
definition block.

## Extensions

Since version 2.0.0, NYNY added support for extensions.
This makes possible to include helpers, middlewares and custom app class
methods inside a single module:

```ruby
module MyKewlExtension
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      env['KEWL'] = true
      @app.call(env) if @app
    end
  end

  module Helpers
    def the_ultimate_answer
      42
    end
  end

  def get_or_post route, &block
    get route, &block
    post route, &block
  end

  def self.registered app
    app.use Middleware
    app.helpers Helpers

    app.get_or_post '/' do
      "After many years of hard computation, the answer is #{the_ultimate_answer}"
    end
  end
end

class App < NYNY::App
  register MyKewlExtension
end

App.run!
```

By default, the App class will `extend` the provided extension module.
Optionally, an extension can add a `registered` method, which will be invoked
once the extension is registered. That method will be called with the app class
as a parameter.

Since NYNY has the same extension interface as Sinatra, some Sinatra extensions
might work with NYNY, although that is not guaranteed. However, an extension
written for NYNY will always work with Sinatra. (Forward compatible)

# F. A. Q.
TBD.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[0]: https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb
[1]: https://github.com/sinatra/sinatra/pull/716
[2]: https://github.com/alisnic/nyny/blob/master/lib/nyny/request_scope.rb
[3]: http://rack.rubyforge.org/doc/classes/Rack/Request.html
[4]: http://rack.rubyforge.org/doc/classes/Rack/Response.html
[performance]: https://github.com/alisnic/nyny/blob/master/Performance.md
[rack-middleware]: https://github.com/rack/rack/wiki/List-of-Middleware
[halt-definition]: https://github.com/alisnic/nyny/blob/master/lib/nyny/request_scope.rb#L36
[primitivesrb]: https://github.com/alisnic/nyny/blob/master/lib/nyny/primitives.rb
[tilt]: https://github.com/rtomayko/tilt
[journey]: https://github.com/rails/journey
[constraints]: http://guides.rubyonrails.org/routing.html#request-based-constraints
[bound-params]: http://guides.rubyonrails.org/routing.html#bound-parameters
