module DpkgTools
  module Package
    module Rails
      module ControlFiles
        class Rakefile < DpkgTools::Package::ControlFiles::Rakefile
          def rakefile
            "require 'rubygems'\n" \
            "begin\n" \
            "  require 'dpkg-tools'\n" \
            "rescue LoadError\n" \
            "  # dpkg-tools not available (because we don't really need it on deployment targets)\n" \
            "end\n" \
            "\n" \
            "if defined?(DpkgTools::Package::Rails)\n" \
            "  DpkgTools::Package::Rails::BuildTasks.new do |t|\n" \
            "    t.base_path = Rake.original_dir\n" \
            "  end\n"
            "end\n"
          end
        end
      end
    end
  end
end