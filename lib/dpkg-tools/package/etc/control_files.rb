require 'dpkg-tools/package/etc/control_files/changelog'

module DpkgTools
  module Package
    module Etc
      module ControlFiles
        class << self
          def classes
            [
              DpkgTools::Package::Etc::ControlFiles::Changelog,
              DpkgTools::Package::ControlFiles::Control,
              DpkgTools::Package::ControlFiles::Copyright,
              DpkgTools::Package::ControlFiles::Rakefile,
              DpkgTools::Package::ControlFiles::Rules
            ]
          end
        end
      end
    end
  end
end
