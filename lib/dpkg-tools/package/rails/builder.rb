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
      class Builder < DpkgTools::Package::Builder
        class << self
          def from_path(path_to_app)
            data = Data.new(path_to_app)
            self.new(data)
          end
        end
        
        def config_options
          {:base_path => data.base_path}
        end
        
        def create_install_dirs
          create_dir_if_needed(File.join(config.etc_install_path, 'apache2/sites-available'))
          create_dir_if_needed(File.join(config.etc_install_path, 'logrotate.d'))
          create_dir_if_needed(File.join(config.etc_install_path, 'init.d'))
          create_dir_if_needed(File.join(config.buildroot, "var/lib/#{data.name}"))
          create_dir_if_needed(File.join(config.buildroot, "var/log/#{data.name}/apache2"))
        end
        
        def generate_conf_file(template_path, target_path)
          File.open(target_path, 'w') do |f|
            f.write(render_template(File.read(template_path)))
          end
        end
        
        def generate_conf_files
          generate_conf_file(File.join(config.base_path, 'config/apache.conf.erb'), 
                             File.join(config.etc_install_path, "apache2/sites-available/#{data.name}"))
          generate_conf_file(File.join(config.base_path, 'config/logrotate.conf.erb'), 
                             File.join(config.etc_install_path, "logrotate.d/#{data.name}"))
          generate_conf_file(File.join(config.base_path, 'config/mongrel_cluster_init.erb'), 
                             File.join(config.buildroot, data.init_script_path))
        end
        
        def read_deployers_ssh_keys
          keys = []
          Dir.entries(data.deployers_ssh_keys_dir).each do |name|
            path = File.join(data.deployers_ssh_keys_dir, name)
            keys << File.read(path) if File.file?(path)
          end
          keys
        end
        
        def write_authorized_keys(ssh_keys)
          authorized_keys_path = File.join(config.buildroot, data.app_install_path, '.ssh/authorized_keys')
          File.open(authorized_keys_path, 'w') { |f| f.write(ssh_keys.join("\n")) }
          sh "chmod 600 \"#{File.join(config.buildroot, data.authorized_keys_path)}\""
        end
        
        def generate_authorized_keys
          create_dir_if_needed(File.join(config.buildroot, data.dot_ssh_path))
          sh "chmod 700 \"#{File.join(config.buildroot, data.dot_ssh_path)}\""
          
          write_authorized_keys(read_deployers_ssh_keys)
        end
        
        def install_package_files
          generate_conf_files
          
          generate_authorized_keys
          
          sh "chmod 755 \"#{File.join(config.buildroot, data.init_script_path)}\""
          sh "chown -R root:root \"#{config.buildroot}\""
        end
      end
    end
  end
end