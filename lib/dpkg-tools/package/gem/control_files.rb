require File.dirname(__FILE__) + '/control_files/control'
require File.dirname(__FILE__) + '/control_files/copyright'
require File.dirname(__FILE__) + '/control_files/changelog'
require File.dirname(__FILE__) + '/control_files/rakefile'

module DpkgTools
  module Package
    module Gem
      module ControlFiles
        class << self
          def classes
            [
              DpkgTools::Package::Gem::ControlFiles::Changelog,
              DpkgTools::Package::Gem::ControlFiles::Control,
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