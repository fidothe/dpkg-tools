module DpkgTools
  module Package
    module Etc
      class Data < DpkgTools::Package::Data
        class << self
          include DpkgTools::Package::Data::YamlConfigHelpers
          
          def resources_dirname
            'etc'
          end
        end
        
        attr_reader :config, :base_path
        
        def initialize(base_path)
          @data = self.class.load_package_data(base_path, 'deb.yml')
          
          @dependencies = self.class.process_dependencies(@data)
          @base_path = base_path
        end
        
        def name
          @data['name']
        end

        def version
          @data['version']
        end

        def license
          @data['license']
        end

        def dependencies
          @dependencies
        end

        def build_dependencies
          @dependencies
        end

        def summary
          @data['summary']
        end
      end
    end
  end
end
