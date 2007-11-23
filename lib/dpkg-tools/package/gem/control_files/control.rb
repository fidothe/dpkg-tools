module DpkgTools
  module Package
    module Gem
      module ControlFiles
        class Control < DpkgTools::Package::ControlFiles::Control
          # Source: package-name
          def source
            config.package_name
          end
          
          # Maintainer: name/email address
          def maintainer
            ["Matt Patterson", "matt@reprocessed.org"]
          end
          
          # Section: hardwired to 'libs' for now
          def section
            'libs'
          end
          
          # Priority: hardwired to 'optional' for now
          def priority
            'optional'
          end
          
          # Build-Depends: build-time package deps
          def build_depends
            [{:name => "rubygems", :requirements => [">= 0.9.4-1"]}, {:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]}] + base_deps(data.dependencies)
          end
          
          # Standards-Version: the version we currently implement
          def standards_version
            DpkgTools::Package.standards_version
          end
          
          # Package: package name for binary .deb
          def package
            config.package_name
          end
          
          # Architecture: Binary package's architecture
          def architecture
            data.debian_arch
          end
          
          # Essential: Hardwired to 'no' because nothing but Debian/Ubuntu base packages are essential
          def essential
            "no"
          end
          
          # Depends: install- and run-time package deps
          def depends
            [{:name => "rubygems", :requirements => [">= 0.9.4-1"]}] + base_deps(data.dependencies)
          end
          
          # Description: We only return the summary for now
          def description
            data.summary
          end
          
          private
          
          def base_deps(dependencies)
            base_deps = []
            dependencies.each do |dependency|
              dep_conf = DpkgTools::Package::Config.new(dependency.name, nil, :suffix => 'rubygem')
              entry = {:name => dep_conf.package_name, :requirements => []}
              dependency.version_requirements.as_list.each do |version|
                entry[:requirements] << "#{version}-1"
              end
              base_deps << entry
            end
            base_deps
          end
        end
      end
    end
  end
end