module DpkgTools
  module Package
    class Setup
      class << self
        include DpkgTools::Package::FSMethods
        
        # Should be overridden by subclasses to check whether the 
        # directory at base_path needs to be bootstrapped in order
        # for a DpkgTools::Package::Data subclass to be instantiated
        def needs_bootstrapping?(base_path)
          bootstrap_files.each do |filename|
            return true unless File.file?(bootstrap_file_path(base_path, filename))
          end
          false
        end
        
        # Should be overridden by subclasses to return the files
        # that are expected to be present under base_path to
        # support a DpkgTools::Package::Data subclass being instantiated
        def bootstrap_files
          ['deb.yml']
        end
        
        # Shoule be overridden by subclasses and return the dir under 
        # base_path where files required by the bootstrapping process
        # should live (can be base_path)
        def bootstrap_file_path(base_path, filename)
          "#{base_path}/#{filename}"
        end
        
        # Should be overridden by subclasses to bootstrap the 
        # directory at base_path, to put it in a state that would 
        # support a DpkgTools::Package::Data subclass being instantiated
        def bootstrap(base_path)
          bootstrap_files.each do |filename|
            bootstrap_file(base_path, filename)
          end
        end
        
        def file_exists?(file_path)
          File.file?(file_path)
        end
        
        def move_original_aside(file_path)
          FileUtils.mv(file_path, file_path + '.bak') 
        end
        
        def copy_bootstrap_file_across(src_file, target_file)
          FileUtils.cp(src_file, target_file)
        end
        
        def bootstrap_file(base_path, filename, options = {})
          target_file = bootstrap_file_path(base_path, filename)
          src_file = File.join(data_class.resources_path, filename)
          file_exists = File.file?(target_file)
          if file_exists && options[:backup]
            move_original_aside(target_file)
            file_exists = false
          end
          copy_bootstrap_file_across(src_file, target_file) unless file_exists
        end
        
        # Should be overridden by subclasses to return the specific 
        # DpkgTools::Package::Data subclass they want to use
        def data_class
          DpkgTools::Package::Data
        end
        
        def from_path(base_path)
          self.bootstrap(base_path) if self.needs_bootstrapping?(base_path)
          self.new(self.data_class.new(base_path), base_path)
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
