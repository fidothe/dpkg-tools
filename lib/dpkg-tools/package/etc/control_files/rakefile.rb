module DpkgTools
  module Package
    module Etc
      module ControlFiles
        class Rakefile < DpkgTools::Package::ControlFiles::Rakefile
          def rakefile
            "require 'rubygems'\n" \
            "require 'dpkg-tools'\n" \
            "\n" \
            "DpkgTools::Package::Etc::BuildTasks.new do |t|\n" \
            "  t.base_path = Rake.original_dir\n" \
            "end\n"
          end
        end
      end
    end
  end
end
