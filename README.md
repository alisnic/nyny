# Frankie
Sinatra's little brother.

## Motivation
Sinatra is a wonderul gem (in both senses), but it fails at one thing: to be an education tool for programmers. This is not bad thing, since it may not be the ultimate goal of such a framework. My efforts to write __Frankie__ started when I wanted to understand how __Sinatra__ works, and stumbled upon the [base.rb][0]. The majority of the classes that are used by sinatra are in one single file, which makes it nearly impossible for a new person to grasp.

[I've tried to change the situation][1], but unfortunately, my initiative was premature for the sinatra project (considering their plans).

I wanted to understand how sinatra works, but the code was pretty challenging. So I decided I should re-implement the basic things sinatra has. Thus, __Frankie__ was born.

## Why you might want to use Frankie instead of Sinatra
- It's very small (200 LOC), which is just a little overhead on top of Rack.
- Sinatra is a drop-in replacement for Frankie. Anytime you feel that you need more, you just change your app to inherit from `Sinatra::Base`, your code will still work, and you will be able to use any of the Sinatra features.
- It's faster than Sinatra (TODO: benchmarks)
- You want to dig into the source code and change to your needs (Frankie's source code is more welcoming)
- Each Frankie app is a Rack middleware, so it can be used inside of Sinatra, Rails, or any other Rack-based app.

## Usage

A Frankie app must _always_ be in a class which inherits from `Frankie::App`.

    #config.ru
    class App < Frankie::App
        get '/' { 'Hello, World' }
    end
    
    run App.new
  
### Defining routes

Frankie supports the following verbs for defining a route: delete, get, head, options, patch, post, put and trace.

    class App < Frankie::App
        post '/' do
            'You Posted, dude!'
        end
    end
    
Frankie also suports basic URL patterns:

    class App < Frankie::App
        get '/greet/:first_name/:last_name' do
            # The last expression in the block is _always_ considered the response body.
            "Hello #{params[:first_name]} #{params[:last_name]}!"
        end
    end

Each block that is passed to a route definition is evaluated in the context of a request scope. See below what methods are available there.

### Request scope
As was said above, when you pass a block to a route definition, that block is evaluated in the context of a [RequestScope][2]. This means that several methods/objects available inside that block:

- `request` - A `Rack::Request` object which encapsulates the request to that route. (see [Rack::Request documentation][3] for more info)
- `params` - a hash which contains both POST body params and GET querystring params.
- `headers` - allows you to add headers to the response (ex: `headers 'Content-Type' => 'text/html'`)
- `status` - allows you to set the status of the response (ex: `status 403`)
- `redirect_to` - sets the response to redirect (ex: `redirect_to 'http://google.com'`)

### Filters

Unlike Sinatra, Frankie supports only "generic" before and after filters. This means that you can't execute a filter depending on a URL pattern.

    class App < Frankie::App
        before do
            headers 'Content-Type' => 'text/html'
        end
        
        after do
            puts response.inspect
        end
 
        get '/' { 'hello' }
    end
    
Before and after filters are also evaluated in a RequestScope context. A little exception are the after filters, which can access the __response__ object ([Rack::Response][4]).

### Middleware

A Fankie app is a Rack middleware, which means that it can be used inside of Sinatra, Rails, or any other Rack-based app:

    class MyApp < Sinatra::Base
        use MyFrankieApp
    end
    
Frankie also supports middleware itself, and that means you can use Rack middleware (or a Sinatra app) inside a Frankie app:

    class App < Frankie::App
        #this will serve all the files in the "public" folder
        use Rack::Static :url => ['public']
        use SinatraApp
    end

### Helpers

Frankie supports helpers as Sinatra does:

    class App < Frankie::App
        helpers MyHelperModule
    end
    
Using a helpers implies that the helpor module is included in the [RequestScope][2], and that all the methods in taht midule will be available inside a route definition block.

## FAQ
TBD.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[0]: https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb
[1]: https://github.com/sinatra/sinatra/pull/716
[2]: https://github.com/alisnic/frankie/blob/master/lib/frankie/request_scope.rb
[3]: http://rack.rubyforge.org/doc/classes/Rack/Request.html
[4]: http://rack.rubyforge.org/doc/classes/Rack/Response.html