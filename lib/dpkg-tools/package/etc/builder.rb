module DpkgTools
  module Package
    module Etc
      class Builder < DpkgTools::Package::Builder
        class << self
          def data_class
            DpkgTools::Package::Etc::Data
          end
        end
        
        def config_options
          {:base_path => data.base_path}
        end
        
        def create_install_dirs
          create_dir_if_needed(config.etc_install_path)
        end
        
        def install_package_files
          FileUtils.cp_r(config.base_path + '/etc', config.etc_install_path)
        end
      end
    end
  end
end
