module DpkgTools
  module Package
    class Setup
      class << self
        include DpkgTools::Package::FSMethods
        
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
      
      def maintainer_script_template_names
        ['postinst.erb', 'postrm.erb', 'preinst.erb', 'prerm.erb']
      end
      
      def copy_maintainer_script_templates
        maintainer_script_template_names.each do |filename|
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
      
      def reset_control_files
        control_file_classes.each do |klass|
          control_file = klass.new(@data, @config)
          if control_file.needs_reset?
            FileUtils.mv(control_file.file_path, control_file.file_path + '.bak') if File.exist?(control_file.file_path)
            control_file.write 
          end
        end
      end
      
      def reset_maintainer_script_templates
        maintainer_script_template_names.each do |filename|
          source = File.join(@data.resources_path, filename)
          target = File.join(@config.debian_path, filename)
          if File.file?(source) && !FileUtils.identical?(source, target)
            FileUtils.mv(target, target + '.bak')
            FileUtils.cp(source, target) 
          end
        end
      end
      
      # This should be overridden to allow features such as the dpkg:setup:regen rake task to 
      # reset the state of package-type specific files (i.e. files that get copied across by
      # prepare_package).
      def reset_package_resource_files
        
      end
    end
  end
end
