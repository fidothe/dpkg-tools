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
          etc_path = config.base_path + '/etc'
          files_to_install = Dir[etc_path + '/**/*']
          files_to_install = Hash[*(files_to_install.collect {|fp| [fp, fp[(etc_path.size)..-1]]}).flatten]
          files_to_install.each do |source_path, target_path|
            if File.file?(source_path)
              target_path = config.etc_install_path + target_path
              FileUtils.mkdir_p(File.dirname(target_path))
              FileUtils.install(source_path, target_path, :mode => 0644, :verbose => true)
            end
          end
        end
      end
    end
  end
end
