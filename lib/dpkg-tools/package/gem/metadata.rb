require File.dirname(__FILE__) + '/metadata/control'
require File.dirname(__FILE__) + '/metadata/copyright'
require File.dirname(__FILE__) + '/metadata/changelog'
require File.dirname(__FILE__) + '/metadata/rakefile'

module DpkgTools
  module Package
    module Gem
      class Metadata
        include MetadataModules::Control
        include MetadataModules::Copyright
        include MetadataModules::Changelog
        include MetadataModules::Rakefile
        
        def initialize(data, config)
          @data = data
          @config = config
        end
        
        private
        
        attr_reader :data, :config
      end
    end
  end
end

