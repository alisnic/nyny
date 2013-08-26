# Frankie vs Sinatra performance test

Note: all the tests below were made using Thin as a webserver. Httperf was
choosen as the tool to do that. Bench settings: `--num-conns 10000`

Hardware: Intel(R) Core(TM) i7-2620M CPU @ 2.70GHz, 6 GB DDR3

If you have a clue how to make proper benchmarks (because, frankly, I don't), I am open to suggestions.

## Results

| Benchmark | Frankie (req/s) | Sinatra (req/s) |
|-----------|:---------------:|:---------------:|
| Simple    |__5012__         |2534             |
| UrlPattern|__4564__         |2338             |
| Filters   |__4510__         |2465             |
| Helpers   |__4737__         |2663             |

See below the code for each benchmark

## Code
### Simple

    class App < Frankie::App #(or Sinatra::Base)
      get '/' do
        'Hello World!'
      end
    end
    
### UrlPattern
    class App < Frankie::App #(or Sinatra::Base)
      get '/hello/:name' do
        "Hello #{params[:name]}!"
      end
    end

### Filters
    class App < Frankie::App #(or Sinatra::Base)
      before do
        request
      end
    
      after do
        response
      end
    
      get '/' do
        'Hello World!'
      end
    end
    
### Helpers
    module Dude
      def da_request_man
        request
      end
    end
    
    class App < Frankie::App #(or Sinatra::Base)
      helpers Dude
    
      get '/' do
        da_request_man
        'Hello World!'
      end
    end

