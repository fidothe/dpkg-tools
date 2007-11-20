module DpkgTools
  module Package
    module Gem
      module MetadataModules
        module Rakefile
          def rakefile
            "require 'rubygems'\n" \
            "require 'dpkg-tools'\n" \
            "\n" \
            "DpkgTools::Package::Gem::BuildTasks.new do |t|\n" \
            "  t.root_path = File.expand_path('../')\n" \
            "  t.gem_path = File.expand_path('./#{config.gem_filename}')\n" \
            "end\n"
          end
        end
      end
    end
  end
end