module DpkgTools
  module Package
    module Etc
      module ControlFiles
        class Changelog < DpkgTools::Package::ControlFiles::Changelog
          def change_time
            Time.now.rfc822
          end
          
          def changelog
            changelog_yaml = YAML::load_file
            "#{config.package_name} (#{config.deb_version(data.debian_revision)}) cp-gutsy; urgency=low\n"\
            "  * Packaged up #{data.full_name}\n"\
            " -- Matt Patterson <matt@reprocessed.org>  #{self.change_time}\n"
          end
        end
      end
    end
  end
end