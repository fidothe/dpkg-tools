module DpkgTools
  module Package
    class Setup
      class << self
        # Should be overridden by subclasses to check whether the 
        # directory at base_path needs to be bootstrapped in order
        # for a DpkgTools::Package::Data subclass to be instantiated
        def needs_bootstrapping?(base_path)
          false
        end
        
        # Should be overridden by subclasses to bootstrap the 
        # directory at base_path needs to allow it to support
        # a DpkgTools::Package::Data subclass being instantiated
        def bootstrap(base_path)
          
        end
      end
      
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
      
      def copy_maintainer_script_templates
        ['post-inst.erb', 'post-rm.erb', 'pre-inst.erb', 'pre-rm.erb'].each do |filename|
          resource = File.join(@data.resources_path, filename)
          FileUtils.cp(resource, File.join(@config.debian_path, filename)) if File.file?(resource)
        end
      end
      
      def prepare_package
      end
      
      def create_structure
        DpkgTools::Package.check_package_dir(@config)
        
        prepare_package
        write_control_files
        copy_maintainer_script_templates
      end
    end
  end
end
