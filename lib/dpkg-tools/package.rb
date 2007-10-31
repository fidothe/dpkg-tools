require File.join(File.dirname(__FILE__), 'package/metadata')
require File.join(File.dirname(__FILE__), 'package/config')
require File.join(File.dirname(__FILE__), 'package/gem')

module DpkgTools
  module Package
    class << self
      def create_gem_structure(gem_name)
        Gem.create_structure(gem_name)
      end
      
      def check_package_dir(package_dir_path)
        Dir.mkdir(package_dir_path) unless File.directory?(package_dir_path)
      end
    end
  end
end