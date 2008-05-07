module DpkgTools
  module Package
    module Etc
      class Data < DpkgTools::Package::Data
        class << self
          def resources_dirname
            'etc'
          end
        end
        
        def dependencies
          []
        end
        
        def build_dependencies
          []
        end
      end
    end
  end
end
