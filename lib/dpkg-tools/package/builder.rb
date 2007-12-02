require 'rake'

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
      
      def architecture_independent?
        @data.architecture_independent?
      end
      
      def create_dir_if_needed(target_path)
        FileUtils.mkdir_p(target_path) unless File.exists?(target_path)
        raise IOError, "the path '#{target_path}' points to a file, so we can't make a directory there." if File.file?(target_path)
      end
      
      def create_intermediate_buildroot
        create_dir_if_needed(config.intermediate_buildroot)
      end
      
      def create_buildroot
        create_dir_if_needed(config.buildroot)
      end
      
      def create_install_dirs
      end
      
      def build_package_files
      end
      
      def install_package_files
      end
      
      def render_template(template)
        conf_file = ERB.new(template, nil, '-').result(data.binding)
      end
      
      def maintainer_script_targets
        names = Dir.entries(config.debian_path).select do |name| 
          ['post-inst.erb', 'pre-inst.erb', 'post-rm.erb', 'pre-rm.erb'].include?(name)
        end
        names.collect { |name| name[/^(.+)\.erb$/, 1] }
      end
      
      def generate_maintainer_script(script_name)
        template = File.read(File.join(config.debian_path, "#{script_name}.erb"))
        target_path = File.join(config.buildroot_DEBIAN_path, script_name)
        File.open(target_path, 'w') do |f|
          f.write(render_template(template))
        end
        File.chmod(0755, target_path)
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
        config.deb_filename(data.debian_revision, data.debian_arch)
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
        build_package_files
      end
      
      def binary_package
        create_buildroot
        create_install_dirs
        install_package_files
        create_DEBIAN_dir
        generate_maintainer_scripts
        create_control_files
        create_deb
      end
      
      def remove_build_products
        FileUtils.remove_dir(config.buildroot) if File.exists?(config.buildroot)
        FileUtils.remove_dir(config.intermediate_buildroot) if File.exists?(config.intermediate_buildroot)
      end
    end
  end
end
