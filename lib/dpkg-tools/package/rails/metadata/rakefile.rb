module DpkgTools
  module Package
    module Rails
      module MetadataModules
        module Rakefile
          def rakefile
            "require 'rubygems'\n" \
            "require 'dpkg-tools'\n" \
            "\n" \
            "DpkgTools::Package::Rails::BuildTasks.new do |t|\n" \
            "  t.base_path = Rake.original_dir\n" \
            "end\n"
          end
        end
      end
    end
  end
end
