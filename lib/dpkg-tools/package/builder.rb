module DpkgTools
  module Package
    class Builder
      attr_reader :data, :config
      
      def initialize(data)
        @data = data
        @config = DpkgTools::Package::Config.new(@data.name, @data.version, config_options)
      end
      
      def config_options
        {}
      end
      
      def create_buildroot
        Dir.mkdir(config.buildroot) unless File.directory?(config.buildroot)
      end
      
      def create_install_dirs
      end
      
      def install_package_files
      end
      
      def render_template(template)
        conf_file = ERB.new(template).result(data.binding)
      end
      
      def maintainer_script_targets
        names = Dir.entries(config.debian_path).select do |name| 
          ['post-inst.erb', 'pre-inst.erb', 'post-rm.erb', 'pre-rm.erb'].include?(name)
        end
        names.collect { |name| name[/^(.+)\.erb$/, 1] }
      end
      
      def generate_maintainer_script(script_name)
        template = File.read(File.join(config.debian_path, "#{script_name}.erb"))
        File.open(File.join(config.debian_path, script_name), 'w') do |f|
          f.write(render_template(template))
        end
      end
      
      def generate_maintainer_scripts
        maintainer_script_targets.each do |target|
          generate_maintainer_script(target)
        end
      end
      
      def create_DEBIAN_dir
        Dir.mkdir(config.buildroot_DEBIAN_path) unless File.directory?(config.buildroot_DEBIAN_path)
      end
      
      # create DEBIAN/* package metadata by running dpkg-gencontrol
      # Note: this assumes that command is run from package base dir
      def create_control_files
        sh "dpkg-gencontrol"
      end
      
      def deb_filename
        config.deb_filename(data.debian_revision, data.debian_architecture)
      end
      
      def built_deb_path
        File.join(config.root_path, deb_filename)
      end
      
      # create the .deb binary package by running dpkg-deb --build with the appropriate options
      def create_deb
        sh "dpkg-deb --build \"#{config.buildroot}\" \"#{built_deb_path}\""
      end
      
      def build_package
        create_buildroot
        create_install_dirs
        install_package_files
        generate_maintainer_scripts
        create_DEBIAN_dir
        create_control_files
        create_deb
      end
      
      def remove_build_products
        FileUtils.remove_dir(config.buildroot) if File.exists?(config.buildroot)
      end
    end
  end
end
