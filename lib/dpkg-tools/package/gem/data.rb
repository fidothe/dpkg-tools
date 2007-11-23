module DpkgTools
  module Package
    module Gem
      class Data < DpkgTools::Package::Data
        attr_reader :spec, :config, :gem_byte_string
        
        def initialize(format, gem_byte_string)
          @format = format
          @gem_byte_string = gem_byte_string
          @spec = format.spec
        end
        
        def name
          @spec.name
        end
        
        def version
          @version ||= @spec.version.to_s
        end
        
        def full_name
          @spec.full_name
        end
        
        def debian_arch
          "i386"
        end
        
        def build_dependencies
          [{:name => "rubygems", :requirements => [">= #{Gem.rubygems_version}-1"]}, 
           {:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]},
           {:name => "dpkg-tools-rubygem", :requirements => [">= #{DpkgTools::VERSION::STRING}-1"]}] + base_deps
        end
        
        def dependencies
          [{:name => "rubygems", :requirements => [">= #{Gem.rubygems_version}-1"]}] + base_deps
        end
        
        def summary
          @spec.summary
        end
        
        def files
          @spec.files
        end
        
        def file_entries
          @format.file_entries
        end
        
        private
        
        def base_deps
          return @base_deps unless @base_deps.nil?
          @base_deps = []
          @spec.dependencies.each do |dependency|
            dep_conf = DpkgTools::Package::Config.new(dependency.name, nil, :suffix => 'rubygem')
            entry = {:name => dep_conf.package_name, :requirements => []}
            dependency.version_requirements.as_list.each do |version|
              entry[:requirements] << "#{version}-1"
            end
            @base_deps << entry
          end
          @base_deps
        end
      end
    end
  end
end