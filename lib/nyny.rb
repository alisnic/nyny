require 'uri'
require 'rack'

require 'nyny/version'
require 'nyny/primitives'
require 'nyny/request_scope'
require 'nyny/route'
require 'nyny/middleware_chain'
require 'nyny/app'
require 'nyny/router'


# Register core extensions
require 'nyny/core-ext/runner'

module NYNY
  App.register NYNY::Runner
end
