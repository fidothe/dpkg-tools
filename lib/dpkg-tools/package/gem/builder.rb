require 'rake'
require 'rubygems'
require 'rubygems/installer'
require 'rubygems/doc_manager'

require 'fileutils'

# module GemBindir
#   class << self
#   def bindir(install_dir = nil)
#     
#   end
# end

module DpkgTools
  module Package
    module Gem
      class Builder < DpkgTools::Package::Builder
        class << self
          def from_file_path(gem_file_path)
            format, gem_byte_string = format_and_file_from_file_path(gem_file_path)
            data = Data.new(format, gem_byte_string)
            self.new(data)
          end
          
          def format_and_file_from_file_path(gem_file_path)
            gem_file = File.open(gem_file_path, 'rb')
            gem_byte_string = gem_file.read
            gem_file.rewind
            format = ::Gem::Format.from_io(gem_file)
            [format, gem_byte_string]
          end
        end
        
        def config_options
          {:suffix => 'rubygem'}
        end
        
        def gem_byte_string
          data.gem_byte_string
        end
        
        def create_install_dirs
          FileUtils.mkdir_p(config.gem_install_path)
          FileUtils.mkdir_p(config.bin_install_path)
        end
        
        def override_gem_bindir
          ::Gem.module_eval %q{def self.bindir(install_dir = nil) "} + config.bin_install_path + %q{" end}
        end
        
        def install_gem
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
        
        def install_package_files
          installed_gem_spec = install_gem
          install_docs(installed_gem_spec)
        end
      end
    end
  end
end