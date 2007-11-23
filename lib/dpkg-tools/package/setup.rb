module DpkgTools
  module Package
    class Setup
      def initialize(data, options = {})
        @data = data
        @config = DpkgTools::Package::Config.new(data.name, data.version, config_options)
      end
      
      def config_options
        {}
      end
      
      def control_file_classes
        DpkgTools::Package::ControlFiles.classes
      end
      
      def write_control_files
        control_file_classes.each do |klass|
          klass.new(@data, @config).write
        end
      end
      
      def create_structure
        DpkgTools::Package.check_package_dir(@config)
        
        prepare_package
        write_control_files
      end
    end
  end
end
