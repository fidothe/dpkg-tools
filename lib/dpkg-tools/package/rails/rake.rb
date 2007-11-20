require 'rake'
require 'rake/tasklib'

module DpkgTools
  module Package
    module Rails
      class BuildTasks < Rake::TaskLib
        attr_accessor :base_path
        
        def initialize
          yield(self) if block_given?
          raise ArgumentError, "Needs to have base_path set" unless @base_path
          
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
            Rake::Task["dpkg-tools:build_package"].invoke
          end
          
          desc "Perform architecture independent post-build install steps"
          task "binary-indep" => "build-indep" do
            Rake::Task["dpkg-tools:build_package"].invoke
          end
          
          desc "Perform all needed build steps"
          task :binary => ["binary-arch", "binary-indep"]
          
          desc "Remove all build and install generated files"
          task :clean do
            builder = DpkgTools::Package::Rails.create_builder(@base_path)
            builder.remove_build_products
          end
          
          namespace "dpkg-tools" do
            task :build_package do
              builder = DpkgTools::Package::Rails.create_builder(@base_path)
              builder.build_package
            end
          end
        end
      end
    end
  end
end