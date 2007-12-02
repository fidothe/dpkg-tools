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
              bootstrap_file(base_path, filename)
            end
          end
          
          def bootstrap_file(base_path, filename)
            target_file = bootstrap_file_path(base_path, filename)
            src_file = File.join(DpkgTools::Package::Rails::Data.resources_path, filename)
            FileUtils.cp(src_file, target_file) unless File.file?(target_file)
          end
          
          def from_path(base_path)
            self.bootstrap(base_path) if self.needs_bootstrapping?(base_path)
            self.new(DpkgTools::Package::Rails::Data.new(base_path), base_path)
          end
          
          def prepare_package(data, config)
            ['apache.conf.erb', 'logrotate.conf.erb'].each do |filename|
              bootstrap_file(config.base_path, filename)
            end
          end
        end
        
        attr_reader :data, :config
        
        def control_file_classes
          DpkgTools::Package::Rails::ControlFiles.classes
        end
        
        def config_options
          {:base_path => @data.base_path}
        end
        
        def prepare_package
          self.class.prepare_package(data, config)
        end
      end
    end
  end
end
