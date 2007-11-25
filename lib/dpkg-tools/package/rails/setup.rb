require 'erb'

module DpkgTools
  module Package
    module Rails
      class Setup < DpkgTools::Package::Setup
        class << self
          def bootstrap_files
            ['deb.yml', 'mongrel_cluster.yml']
          end
          
          def bootstrap_file_path(base_path, filename)
            File.join(base_path, 'config', filename)
          end
          
          def needs_bootstrapping?(base_path)
            bootstrap_files.each do |filename|
              return true unless File.file?(bootstrap_file_path(base_path, filename))
            end
            false
          end
          
          def bootstrap(base_path)
            bootstrap_files.each do |filename|
              bootstrap_file(filename, base_path)
            end
          end
          
          def bootstrap_file(base_path, filename)
            target_file = bootstrap_file_path(base_path, filename)
            src_file = File.join(DpkgTools::Package::Rails::Data.resources_path, filename)
            FileUtils.cp(src_file, target_file) unless File.file?(target_file)
          end
          
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
          
          def prepare_package(data, config)
            FileUtils.cp(File.join(DpkgTools::Package::Rails::Data.resources_path, 'apache.conf.erb'), 
              File.join(config.base_path, 'config/apache.conf.erb'))
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
      end
    end
  end
end
