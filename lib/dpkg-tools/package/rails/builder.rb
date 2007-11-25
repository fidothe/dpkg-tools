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
          FileUtils.mkdir_p(File.join(config.etc_install_path, 'apache2/sites-available'))
          FileUtils.mkdir_p(File.join(config.etc_install_path, 'init.d'))
          FileUtils.mkdir_p(File.join(config.buildroot, "var/lib/#{config.name}-app"))
        end
        
        def mongrel_cluster_init_script_path
          File.join(::Gem.source_index.find_name('mongrel_cluster', [">0"]).last.full_gem_path, 'resources/mongrel_cluster')
        end
        
        def generate_apache_conf
          template = File.read(File.join(config.base_path, 'config/apache.conf.erb'))
          
          File.open(File.join(config.etc_install_path, "apache2/sites-available/#{config.name}.conf"), 'w') do |f|
            f.write(render_template(template))
          end
        end
        
        def install_package_files
          generate_apache_conf
          
          FileUtils.cp(mongrel_cluster_init_script_path, 
                       File.join(config.etc_install_path, "init.d/mongrel_cluster"))
        end
      end
    end
  end
end