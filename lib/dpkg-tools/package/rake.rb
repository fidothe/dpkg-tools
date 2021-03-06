require 'rake'
require 'rake/tasklib'

module DpkgTools
  module Package
    class BuildTasks < Rake::TaskLib
      def initialize
        yield(self) if block_given?
        
        check_setup
        define_base_tasks
        define_tasks
      end
      
      # Override this to check that people did the right thing in the block on init
      def check_setup
        
      end
      
      # Override this to define subclass-specific building functionality
      def define_tasks
        
      end
      
      # Override this method to properly return an instantiated Builder object
      # You can use this yourself for the build steps, and it's used by :clean
      # to invoke remove_build_products on your builder
      def create_builder
        
      end
      
      # Override this method to properly return an instantiated Setup object.
      # This is used by the setup helpers, like dpkg:setup:diff and dpkg:setup:regen
      def create_setup
        
      end
      
      # Defines the base rake tasks and ensures that you only need to define the create_builder function and 
      # build-arch, build-indep, binary-arch and binary-indep tasks as you need to
      def define_base_tasks
        # build
        desc "Perform architecture-dependent build steps"
        task "build-arch"
        
        desc "Perform architecture-independent build steps"
        task "build-indep"
        
        desc "Perform all needed build steps"
        task :build do
          package_type = create_builder.architecture_independent? ? 'indep' : 'arch'
          Rake::Task["build-#{package_type}"].invoke
        end
        
        desc "Perform architecture dependent post-build install steps"
        task "binary-arch"
        
        desc "Perform architecture independent post-build install steps"
        task "binary-indep"
        
        desc "Perform all needed build steps"
        task :binary do
          package_type = create_builder.architecture_independent? ? 'indep' : 'arch'
          Rake::Task["binary-#{package_type}"].invoke
        end
        
        desc "Remove all build and install generated files"
        task :clean do
          create_builder.remove_build_products
        end
        
        # dpkg-tools rake tasks
        namespace :dpkg do
          desc <<-EOD
            Reset any files generated during initial setup to their pristine state.
            Any of those files modified by you will be moved to <file_name>.bak first.
            Identical files won't be touched.
          EOD
          task :reset do
            setup = create_setup
            setup.reset_maintainer_script_templates
            setup.reset_control_files
            setup.reset_package_resource_files
          end
          desc <<-EOD
            Regenerate the control files.
            Any of those files modified by you will be moved to <file_name>.bak first.
          EOD
          task :control do
            setup = create_setup
            setup.reset_control_files
          end
        end
      end
    end
  end
end