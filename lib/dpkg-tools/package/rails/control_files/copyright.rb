module DpkgTools
  module Package
    module Rails
      module ControlFiles
        class Copyright < DpkgTools::Package::ControlFiles::Copyright
          def license_file
            data.license
          end
        end
      end
    end
  end
end