# Frankie vs Sinatra performance test

Note: all the tests below were made using Thin as a webserver. Httperf was
choosen as the tool to do that. Bench settings: `--num-conns 20000`

Hardware: Intel(R) Core(TM) i7-2620M CPU @ 2.70GHz, 6 GB DDR3


| Benchmark | Frankie (req/s) | Sinatra (req/s) |
|-----------|:---------------:|:---------------:|
| Simple    |__4838__         |2328             |

See below the code for each benchmark

## Simple

    class App < Frankie::App #(or Sinatra::Base)
      get '/' do
        'Hello World!'
      end
    end

    Rack::Handler::Thin.run App.new, :Port => 9000


