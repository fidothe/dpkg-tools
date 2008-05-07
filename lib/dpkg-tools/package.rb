require 'dpkg-tools/package/config'
require 'dpkg-tools/package/data'
require 'dpkg-tools/package/control_files'
require 'dpkg-tools/package/fs_methods'
require 'dpkg-tools/package/setup'
require 'dpkg-tools/package/builder'
require 'dpkg-tools/package/rake'

require 'dpkg-tools/package/gem'
require 'dpkg-tools/package/rails'
require 'dpkg-tools/package/etc'

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