require 'little_frank'
require 'rack'
include LittleFrank

def extended_modules_for kls
  (class << kls; self end).included_modules
end

def mock_request method, url, kls=App
  kls.new.call Rack::MockRequest.env_for(url, :method => method)
end

def random_url levels=1
  parts = levels.times.map do
    SecureRandom.urlsafe_base64
  end

  "/#{parts.join('/')}"
end
