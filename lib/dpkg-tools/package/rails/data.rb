module DpkgTools
  module Package
    module Rails
      class Data
        class << self
          def load_package_data(base_path)
            YAML.load_file(File.join(base_path, "config/deb.yml")) if File.exist?(File.join(base_path, "config/deb.yml"))
          end
        end
        
        attr_reader :spec
        
        def initialize(base_path)
          @data = self.class.load_package_data(base_path)
          @config = DpkgTools::Package::Config.new(name, version)
        end
        
        def name
          @data["name"]
        end
        
        def version
          @data["version"]
        end
        
        def debian_revision
          "1"
        end
        
        def debian_arch
          "all"
        end
        
        def deb_filename
          @config.deb_filename(debian_arch)
        end
      end
    end
  end
end
