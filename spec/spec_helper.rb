lib_path = File.expand_path(File.dirname(__FILE__) + "/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'dpkg-tools'

module ArrayContentMatcher
  class HaveTheSameContentsAs
    def initialize(expected)
      @expected = expected
    end
    def matches?(target)
      @target = target
      target_clone = @target + []
      expected_clone = @expected + []
      return false unless @target.size == @expected.size
      while target_clone.size > 0
        item = target_clone.shift
        if expected_clone.include?(item)
          expected_clone.delete_at(expected_clone.index(item))
        else
          return false
        end
      end
      true
    end
    
    def failure_message
      "expected #{@target.inspect} to contain the same items, in any order, as #{@expected.inspect}"
    end
    
    def negative_failure_message
      "expected #{@target.inspect} not to contain the same items as #{@expected.inspect}"
    end
  end

  def have_the_same_contents_as(expected)
    HaveTheSameContentsAs.new(expected)
  end
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.include(ArrayContentMatcher)
end