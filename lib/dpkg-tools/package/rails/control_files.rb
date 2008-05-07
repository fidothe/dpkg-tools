require 'dpkg-tools/package/rails/control_files/copyright'
require 'dpkg-tools/package/rails/control_files/changelog'
require 'dpkg-tools/package/rails/control_files/rakefile'

module DpkgTools
  module Package
    module Rails
      module ControlFiles
        class << self
          def classes
            [
              DpkgTools::Package::Rails::ControlFiles::Changelog,
              DpkgTools::Package::ControlFiles::Control,
              DpkgTools::Package::Rails::ControlFiles::Copyright,
              DpkgTools::Package::Rails::ControlFiles::Rakefile,
              DpkgTools::Package::ControlFiles::Rules
            ]
          end
        end
      end
    end
  end
end