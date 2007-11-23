require File.dirname(__FILE__) + '/control_files/control'
require File.dirname(__FILE__) + '/control_files/copyright'
require File.dirname(__FILE__) + '/control_files/changelog'
require File.dirname(__FILE__) + '/control_files/rakefile'

module DpkgTools
  module Package
    module Rails
      module ControlFiles
        class << self
          def classes
            [
              DpkgTools::Package::Rails::ControlFiles::Changelog,
              DpkgTools::Package::Rails::ControlFiles::Control,
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