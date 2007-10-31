require 'rake'
require 'rubygems/installer'
require 'rubygems/doc_manager'

require 'fileutils'

module DpkgTools
  module Package
    module Gem
      class Builder
        class << self
          def from_file_path(gem_file_path)
            format, gem_byte_string = format_and_file_from_file_path(gem_file_path)
            data = Data.new(format)
            self.new(data, gem_byte_string)
          end
          
          def format_and_file_from_file_path(gem_file_path)
            gem_file = File.open(gem_file_path, 'rb')
            gem_byte_string = gem_file.read
            gem_file.rewind
            format = ::Gem::Format.from_io(gem_file)
            [format, gem_byte_string]
          end
        end
        
        attr_reader :data, :gem_byte_string
        
        def initialize(data, gem_byte_string)
          @data = data
          @gem_byte_string = gem_byte_string
        end
        
        def config
          DpkgTools::Package.config(data.config_key)
        end
        
        def create_buildroot
          Dir.mkdir(config.buildroot) unless File.directory?(config.buildroot)
        end
        
        def create_install_dirs
          FileUtils.mkdir_p(config.gem_install_path)
          FileUtils.mkdir_p(config.bin_install_path)
        end
        
        def create_DEBIAN_dir
          Dir.mkdir(config.buildroot_DEBIAN_path) unless File.directory?(config.buildroot_DEBIAN_path)
        end
        
        def override_gem_bindir
          eval("def Gem.bindir(install_dir = nil)\n\"#{config.bin_install_path}\"\nend\n")
        end
        
        def install_gem
          conf = DpkgTools::Package.config(data.config_key)
          override_gem_bindir
          installer = ::Gem::Installer.new(config.gem_path, {:wrappers => true, :env_shebang => true})
          installer.install(false, config.gem_install_path)
        end
        
        # installs RDoc / RI docs
        def install_docs(installed_gem_spec)
          doc_manager = ::Gem::DocManager.new(installed_gem_spec)
          doc_manager.generate_ri
          doc_manager.generate_rdoc
        end
        
        # create DEBIAN/* package metadata by running dpkg-gencontrol
        # Note: this assumes that command is run from package base dir
        def create_control_files
          sh "dpkg-gencontrol"
        end
        
        def deb_filename
          data.deb_filename
        end
        
        def built_deb_path
          "#{config.root_path}/#{deb_filename}"
        end
        
        # create the .deb binary package by running dpkg-deb --build with the appropriate options
        def create_deb
          sh "dpkg-deb --build \"#{config.buildroot}\" \"#{built_deb_path}\""
        end
        
        def build_package
          create_buildroot
          create_install_dirs
          create_DEBIAN_dir
          installed_gem_spec = install_gem
          install_docs(installed_gem_spec)
          create_control_files
          create_deb
        end
        
        def remove_build_products
          FileUtils.remove_dir(config.buildroot) if File.exists?(config.buildroot)
        end
      end
    end
  end
end