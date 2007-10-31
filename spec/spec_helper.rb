begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require File.dirname(__FILE__) + '/../lib/dpkg-tools'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end