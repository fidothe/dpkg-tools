require 'rake'
require 'rake/tasklib'

module DpkgTools
  module Package
    module Rails
      class BuildTasks < DpkgTools::Package::BuildTasks
        attr_accessor :base_path
        
        def check_setup
          raise ArgumentError, "Needs to have base_path set" unless @base_path
        end
        
        def create_builder
          DpkgTools::Package::Rails.create_builder(@base_path)
        end
        
        def create_setup
          DpkgTools::Package::Rails.create_setup(@base_path)
        end
        
        def define_tasks
          task "binary-arch" do
            create_builder.binary_package
          end
          
          task "binary-indep" do
            create_builder.binary_package
          end
          
          namespace :dpkg do
            desc <<-EOD
              Regenerate the config/mongre_cluster.yml file.
            EOD
            task :mongrel_cluster do
              create_setup.generate_mongrel_cluster_config
            end
          end
        end
      end
    end
  end
end