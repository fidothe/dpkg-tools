require File.join(File.dirname(__FILE__), 'package/metadata')
require File.join(File.dirname(__FILE__), 'package/config')
require File.join(File.dirname(__FILE__), 'package/data')
require File.join(File.dirname(__FILE__), 'package/control_files')
require File.join(File.dirname(__FILE__), 'package/setup')
require File.join(File.dirname(__FILE__), 'package/gem')
require File.join(File.dirname(__FILE__), 'package/rails')

module DpkgTools
  module Package
    class << self
      def create_gem_structure(gem_name)
        Gem.create_structure(gem_name)
      end
      
      def check_package_dir(config)
        package_dir_path = config.base_path
        Dir.mkdir(package_dir_path) unless File.directory?(package_dir_path)
      end
      
      def standards_version
        "3.7.2"
      end
    end
  end
end