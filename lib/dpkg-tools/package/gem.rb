require 'dpkg-tools/package/gem/data'
require 'dpkg-tools/package/gem/setup'
require 'dpkg-tools/package/gem/control_files'
require 'dpkg-tools/package/gem/builder'
require 'dpkg-tools/package/gem/rake'

module DpkgTools
  module Package
    module Gem
      class << self
        def setup_from_path(gem_path, options = {})
          Setup.from_path(gem_path).create_structure
        end
        
        def setup_from_name(gem_name, options = {})
          setup = Setup.from_name(gem_name)
          unless options[:ignore_dependencies]
            setup.fetch_dependencies.each do |dependency|
              dependency.create_structure
            end
          end
          setup.create_structure
        end
        
        def create_builder(path_to_gem_file)
          Builder.from_file_path(path_to_gem_file)
        end
        
        def config_cache(name_version_pair)
          name, version = name_version_pair
          @config_cache ||= {}
          @config_cache[name_version_pair] ||= DpkgTools::Package::Config.new(name, version, :suffix => 'rubygem')
          yield(@config_cache[name_version_pair]) if block_given?
          @config_cache[name_version_pair]
        end
        
        def rubygems_version
          "0.9.4"
        end
      end
    end
  end
end