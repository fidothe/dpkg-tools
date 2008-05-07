require 'dpkg-tools/package/gem/control_files/copyright'
require 'dpkg-tools/package/gem/control_files/changelog'
require 'dpkg-tools/package/gem/control_files/rakefile'

module DpkgTools
  module Package
    module Gem
      module ControlFiles
        class << self
          def classes
            [
              DpkgTools::Package::Gem::ControlFiles::Changelog,
              DpkgTools::Package::ControlFiles::Control,
              DpkgTools::Package::Gem::ControlFiles::Copyright,
              DpkgTools::Package::Gem::ControlFiles::Rakefile,
              DpkgTools::Package::ControlFiles::Rules
            ]
          end
        end
      end
    end
  end
end