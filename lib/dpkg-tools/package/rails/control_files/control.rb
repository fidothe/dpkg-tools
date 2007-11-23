module DpkgTools
  module Package
    module Rails
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
            data.build_dependencies
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
            data.dependencies
          end
          
          # Description: We only return the summary for now
          def description
            data.summary
          end
        end
      end
    end
  end
end