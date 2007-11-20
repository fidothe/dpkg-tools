require 'rake'
require 'rubygems'

require 'fileutils'

# module GemBindir
#   class << self
#   def bindir(install_dir = nil)
#     
#   end
# end

module DpkgTools
  module Package
    module Rails
      class Builder
        class << self
          def from_path(path_to_app)
            data = Data.new(path_to_app)
            self.new(data)
          end
        end
        
        attr_reader :data
        
        def initialize(data)
          @data = data
        end
        
        def config
          data.config
        end
        
        def create_buildroot
          Dir.mkdir(config.buildroot) unless File.directory?(config.buildroot)
        end
        
        def create_install_dirs
          FileUtils.mkdir_p(File.join(config.etc_install_path, 'apache2/sites-available'))
          FileUtils.mkdir_p(File.join(config.etc_install_path, 'init.d'))
          FileUtils.mkdir_p(File.join(config.buildroot, "var/lib/#{config.name}-app"))
        end
        
        def mongrel_cluster_init_script_path
          File.join(::Gem.source_index.find_name('mongrel_cluster', [">0"]).last.full_gem_path, 'resources/mongrel_cluster')
        end
        
          
        def render_apache_conf(template, cluster_config)
          struct = OpenStruct.new(:mongrels => Array.new(cluster_config['servers']) {|i| (cluster_config['port'].to_i + i).to_s})
          conf_file = ERB.new(template).result(struct.instance_eval { binding })
        end
        
        def generate_apache_conf
          cluster_config = YAML.load_file(File.join(config.base_path, 'config/mongrel_cluster.yml'))
          template = File.read(File.join(config.base_path, 'config/apache.conf.erb'))
          
          File.open(File.join(config.etc_install_path, "apache2/sites-available/#{config.name}.conf"), 'w') do |f|
            f.write(render_apache_conf(template, cluster_config))
          end
        end
        
        def install_conf_files
          generate_apache_conf
          
          FileUtils.cp(mongrel_cluster_init_script_path, 
                       File.join(config.etc_install_path, "init.d/mongrel_cluster"))
        end
        
        def create_DEBIAN_dir
          Dir.mkdir(config.buildroot_DEBIAN_path) unless File.directory?(config.buildroot_DEBIAN_path)
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
          "#{config.root_path}/#{data.deb_filename}"
        end
        
        # create the .deb binary package by running dpkg-deb --build with the appropriate options
        def create_deb
          sh "dpkg-deb --build \"#{config.buildroot}\" \"#{built_deb_path}\""
        end
        
        def build_package
          create_buildroot
          create_install_dirs
          create_DEBIAN_dir
          install_conf_files
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