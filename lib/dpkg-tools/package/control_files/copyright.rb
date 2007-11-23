module DpkgTools
  module Package
    module ControlFiles
      class Copyright < DpkgTools::Package::ControlFiles::Base
        class << self
          def filename
            'copyright'
          end
          
          def formatter_class
            CopyrightFormatter
          end
        end
      end
      
      class CopyrightFormatter < DpkgTools::Package::ControlFiles::BaseFormatter
        def build
          metadata.license_file
        end
      end
    end
  end
end