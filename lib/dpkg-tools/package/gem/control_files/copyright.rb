module DpkgTools
  module Package
    module Gem
      module ControlFiles
        class Copyright < DpkgTools::Package::ControlFiles::Copyright
          def license_file
            # first, look for LICENSE or MIT-LICENSE in the gem
            licenses = data.files.select do |file_path|
              (file_path.match(/license/i) || file_path.match(/copying/i)) unless file_path.nil?
            end
            
            if licenses.size == 1
              license_path = licenses.first
              license_files = data.file_entries.select do |meta, data|
                meta["path"] == license_path
              end
              license_files.first[1]
            end
          end
        end
      end
    end
  end
end