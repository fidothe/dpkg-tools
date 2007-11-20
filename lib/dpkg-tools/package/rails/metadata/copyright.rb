module DpkgTools
  module Package
    module Rails
      module MetadataModules
        module Copyright
          def license_file
            data.license
          end
        end
      end
    end
  end
end
