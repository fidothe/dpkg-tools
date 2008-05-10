require 'dpkg-tools/package/etc/data'
require 'dpkg-tools/package/etc/setup'
require 'dpkg-tools/package/etc/builder'
require 'dpkg-tools/package/etc/control_files'
require 'dpkg-tools/package/etc/rake'

module DpkgTools
  module Package
    module Etc
      class << self
        def create_builder(path_to_app)
          Builder.from_path(path_to_app)
        end
        
        def create_setup(path_to_app)
          Setup.from_path(path_to_app)
        end
        
        def setup_from_path(path_to_app)
          Dir.mkdir(path_to_app) unless File.directory?(path_to_app)
          create_setup(path_to_app).create_structure
        end
      end
    end
  end
end