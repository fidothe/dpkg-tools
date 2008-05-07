module DpkgTools
  module Package
    module Etc
      class Setup < DpkgTools::Package::Setup
        class << self
          def data_class
            DpkgTools::Package::Etc::Data
          end
          
          def bootstrap_files
            ['deb.yml', 'changelog.yml']
          end
        end
      end
    end
  end
end
