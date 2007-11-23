module DpkgTools
  module Package
    module ControlFiles
      class Rakefile < DpkgTools::Package::ControlFiles::Base
        class << self
          def filename
            nil
          end
          
          def formatter_class
            RakefileFormatter
          end
        end
        
        def file_path
          base_method, filename = @data.rakefile_location
          File.join(@config.send(base_method), filename)
        end
      end
      
      class RakefileFormatter < DpkgTools::Package::ControlFiles::BaseFormatter
        def build
          metadata.rakefile
        end
      end
    end
  end
end