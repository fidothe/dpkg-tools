module DpkgTools
  module Package
    module Rails
      module ControlFiles
        class Changelog < DpkgTools::Package::ControlFiles::Changelog
          def change_time
            Time.now.rfc822
          end
          
          def changelog
            "#{config.package_name} (#{config.deb_version(data.debian_revision)}) cp-gutsy; urgency=low\n"\
            "  * Packaged up #{data.full_name}\n"\
            " -- Matt Patterson <matt@reprocessed.org>  #{self.change_time}\n"
          end
        end
      end
    end
  end
end