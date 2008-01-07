module DpkgTools
  module Package
    module Rails
      class << self
        def cap
          DpkgTools::Package::Rails::Data.new(DpkgTools::Package::Rails::Cap.located_app_root)
        end
      end
      
      module Cap
        class << self
          def dir_contains_config?(path)
            Dir.entries(path).include?('config')
          end
          
          def located_app_root
            path = Dir.pwd
            while path != '/'
              return path if dir_contains_config?(path)
              path = File.dirname(path)
            end
            raise CannotLocateAppDir
          end
        end
      end
      
      class CannotLocateAppDir < StandardError; end
    end
  end
end