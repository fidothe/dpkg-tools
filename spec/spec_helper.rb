begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'lib/dpkg-tools'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end