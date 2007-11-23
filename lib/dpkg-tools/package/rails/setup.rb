require 'erb'

module DpkgTools
  module Package
    module Rails
      class Setup < DpkgTools::Package::Setup
        class << self
          def from_path(base_path)
            self.new(DpkgTools::Package::Rails::Data.new(base_path), base_path)
          end
          
          def resources_path
            File.expand_path(File.join(File.dirname(__FILE__), '../../../../resources'))
          end
          
          def create_deb_yaml(base_path)
            FileUtils.cp(File.join(resources_path, 'deb.yml'), File.join(base_path, 'config/deb.yml'))
          end
          
          def create_apache_conf_template(base_path)
            FileUtils.cp(File.join(resources_path, 'apache.conf.erb'), File.join(base_path, 'config/apache.conf.erb'))
          end
          
          def create_mongrel_cluster_conf_yaml(base_path)
            FileUtils.cp(File.join(resources_path, 'mongrel_cluster.yml'), File.join(base_path, 'config/mongrel_cluster.yml'))
          end
          
          def create_config_files(base_path)
            create_mongrel_cluster_conf_yaml(base_path)
            create_apache_conf_template(base_path)
            create_deb_yaml(base_path)
          end
        end
        
        attr_reader :data, :config
        
        def control_file_classes
          DpkgTools::Package::Rails::ControlFiles.classes
        end
        
        def config_options
          {:base_path => @data.base_path}
        end
        
        def prepare_structure
        end
      end
    end
  end
end
