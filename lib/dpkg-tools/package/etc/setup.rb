module DpkgTools
  module Package
    module Etc
      class Setup < DpkgTools::Package::Setup
        class << self
          def data_class
            DpkgTools::Package::Etc::Data
          end
          
          def bootstrap_files
            ['deb.yml', 'changelog.yml']
          end
        end
        
        def control_file_classes
          DpkgTools::Package::Etc::ControlFiles.classes
        end
        
        def config_options
          {:base_path => @data.base_path}
        end
        
        def prepare_package
          etc_path = @config.base_path + '/etc'
          Dir.mkdir(etc_path) unless File.directory?(etc_path)
        end
      end
    end
  end
end
