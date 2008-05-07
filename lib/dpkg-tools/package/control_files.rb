require 'dpkg-tools/package/control_files/base'
require 'dpkg-tools/package/control_files/control'
require 'dpkg-tools/package/control_files/copyright'
require 'dpkg-tools/package/control_files/changelog'
require 'dpkg-tools/package/control_files/rules'
require 'dpkg-tools/package/control_files/rakefile'

module DpkgTools
  module Package
    module ControlFiles
      class << self
        def classes
          [
            DpkgTools::Package::ControlFiles::Changelog,
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