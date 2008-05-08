module DpkgTools
  module Package
    module Gem
      class BuildTasks < DpkgTools::Package::BuildTasks
        attr_accessor :gem_path, :root_path
        
        def check_setup
          raise ArgumentError, "Needs to have gem_path and root_path set" unless @gem_path && @root_path
          DpkgTools::Package::Config.root_path = self.root_path
        end
        
        def create_builder
          DpkgTools::Package::Gem.create_builder(@gem_path)
        end
        
        def define_tasks
          # build
          task "build-arch" do
            create_builder.build_package
          end
          
          task "build-indep" do
            create_builder.build_package
          end
          
          task "binary-arch" do
            create_builder.binary_package
          end
          
          task "binary-indep" do
            create_builder.binary_package
          end
        end
      end
    end
  end
end