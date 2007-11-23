module DpkgTools
  module Package
    module ControlFiles
      class Changelog < DpkgTools::Package::ControlFiles::Base
        class << self
          def filename
            'changelog'
          end
          
          def formatter_class
            ChangelogFormatter
          end
        end
      end
      
      class ChangelogFormatter < DpkgTools::Package::ControlFiles::BaseFormatter
        def build
          metadata.changelog
        end
      end
    end
  end
end