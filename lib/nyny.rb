require 'uri'
require 'rack'

module NYNY
  VERSION = "1.0.0.pre1"
end

require 'nyny/primitives'
require 'nyny/request_scope'
require 'nyny/route_signature'
require 'nyny/runner'
require 'nyny/middleware_chain'
require 'nyny/route_matcher'
require 'nyny/app'
