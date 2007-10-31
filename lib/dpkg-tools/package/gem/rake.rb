require 'rake'
require 'rake/tasklib'

module DpkgTools
  module Package
    module Gem
      class BuildTasks < Rake::TaskLib
        attr_accessor :gem_path, :root_path
        
        def initialize
          yield(self) if block_given?
          raise ArgumentError, "Needs to have gem_path and root_path set" unless @gem_path && @root_path
          
          DpkgTools::Package::Config.root_path = self.root_path
          define
        end
        
        def define
          # build
          desc "Perform architecture-dependent build steps"
          task "build-arch"
          
          desc "Perform architecture-independent build steps"
          task "build-indep"
          
          desc "Perform all needed build steps"
          task :build => ["build-arch", "build-indep"]
          
          desc "Perform architecture dependent post-build install steps"
          task "binary-arch" => "build-arch" do
            builder = DpkgTools::Package::Gem.create_builder(@gem_path)
            builder.build_package
          end
          
          desc "Perform architecture independent post-build install steps"
          task "binary-indep" => "build-indep"
          
          desc "Perform all needed build steps"
          task :binary => ["binary-arch", "binary-indep"]
          
          desc "Remove all build and install generated files"
          task :clean do
            builder = DpkgTools::Package::Gem.create_builder(@gem_path)
            builder.remove_build_products
          end
        end
      end
    end
  end
end