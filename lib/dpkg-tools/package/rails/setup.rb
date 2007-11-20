require 'erb'

module DpkgTools
  module Package
    module Rails
      class Setup
        class << self
          def from_path(base_path)
            self.new(DpkgTools::Package::Rails::Data.new(base_path), base_path)
          end
          
          def resources_path
            File.expand_path(File.join(File.dirname(__FILE__), '../../../../resources'))
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
          end
        end
        
        attr_reader :data, :config
        
        def initialize(data, base_path)
          @data = data
          @config = DpkgTools::Package::Config.new(@data.name, @data.version, :base_path => base_path)
        end
        
        def config_key
          @data.config_key
        end
        
        def create_structure
          DpkgTools::Package.check_package_dir(config.base_path)
          self.class.create_config_files(config.base_path)
          write_control_files
        end
        
        def write_control_files
          DpkgTools::Package::Metadata.write_control_files(data)
        end
      end
    end
  end
end
