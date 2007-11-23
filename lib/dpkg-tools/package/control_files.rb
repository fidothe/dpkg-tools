require File.dirname(__FILE__) + '/control_files/base'
require File.dirname(__FILE__) + '/control_files/control'
require File.dirname(__FILE__) + '/control_files/copyright'
require File.dirname(__FILE__) + '/control_files/changelog'
require File.dirname(__FILE__) + '/control_files/rules'
require File.dirname(__FILE__) + '/control_files/rakefile'

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