module DpkgTools
  module Package
    module ControlFiles
      class Rules < DpkgTools::Package::ControlFiles::Base
        class << self
          def filename
            'rules'
          end
          
          def formatter_class
            RulesFormatter
          end
        end
        
        def executable?
          true
        end
      end
      
      class RulesFormatter < DpkgTools::Package::ControlFiles::BaseFormatter
        def build
          "#!/bin/sh\n" \
          "\n" \
          "/usr/bin/rake $@\n" \
        end
      end
    end
  end
end