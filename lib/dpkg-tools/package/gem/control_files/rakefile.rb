module DpkgTools
  module Package
    module Gem
      module ControlFiles
        class Rakefile < DpkgTools::Package::ControlFiles::Rakefile
          def rakefile
            "require 'rubygems'\n" \
            "require 'dpkg-tools'\n" \
            "\n" \
            "DpkgTools::Package::Gem::BuildTasks.new do |t|\n" \
            "  t.root_path = File.dirname(Rake.original_dir)\n" \
            "  t.gem_path = File.join(Rake.original_dir, '#{config.gem_filename}')\n" \
            "end\n"
          end
        end
      end
    end
  end
end