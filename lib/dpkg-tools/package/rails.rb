require File.join(File.dirname(__FILE__), 'rails/data')
require File.join(File.dirname(__FILE__), 'rails/setup')
require File.join(File.dirname(__FILE__), 'rails/builder')
require File.join(File.dirname(__FILE__), 'rails/metadata')
require File.join(File.dirname(__FILE__), 'rails/rake')

module DpkgTools
  module Package
    module Rails
      class << self
        def create_builder(path_to_app)
          Builder.from_path(path_to_app)
        end
        
        def setup_from_path(path_to_app)
          Setup.create_config_files(path_to_app)
          Setup.from_path(path_to_app).create_structure
        end
      end
    end
  end
end