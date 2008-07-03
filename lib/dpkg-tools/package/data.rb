module DpkgTools
  module Package
    class DebYAMLParseError < StandardError; end
    
    class Data
      module YamlConfigHelpers
        # Should be overridden by subclasses to return a list of base (i.e. always required, 
        # don't need to be specified) gem dependencies. Should return an array of hashes 
        # of the form {:name => 'rails-rubygem', :requirements => ['>= 1.2.5-1']}
        def base_gem_deps
          []
        end
        
        # Should be overridden by subclasses to return a list of base (i.e. always required, 
        # don't need to be specified) dpkg package dependencies. Should return an array of hashes 
        # of the form {:name => 'mysql-server', :requirements => ['>= 1.2.5-1']}
        def base_package_deps
          []
        end
        
        def package_data_file_path(base_path, filename)
          File.join(base_path, filename)
        end
        
        def load_package_data(base_path, filename)
          file_path = package_data_file_path(base_path, filename)
          YAML.load_file(file_path) if File.exist?(file_path)
        end
        
        def process_dependencies(data)
          all_deps = base_gem_deps + base_package_deps
          if data.has_key?('dependencies') && !data['dependencies'].empty?
            raise DebYAMLParseError, "dependencies: is not a collection of items!" unless data['dependencies'].kind_of?(Hash)
            all_deps += process_dependencies_by_type(data['dependencies'], 'gem', 'rubygem') {|req| "#{req}-1"}
            all_deps += process_dependencies_by_type(data['dependencies'], 'package')
          end
          all_deps
        end
        
        def process_dependencies_by_type(dependencies, dependency_type, suffix = nil)
          processed_dependencies = []
          if dependencies.has_key?(dependency_type)
            dependencies_to_process = dependencies[dependency_type]
            unless dependencies_to_process.kind_of?(Array) || dependencies_to_process.nil?
              raise DebYAMLParseError, "dependencies: #{dependency_type}: is not a list of items!"
            end
            unless dependencies_to_process.nil?
              dependencies_to_process.each do |dependency|
                name = dependency.kind_of?(Hash) ? dependency.keys.first : dependency
                requirements = dependency.kind_of?(Hash) ? dependency.values.first : nil
                unless requirements.kind_of?(Array) || requirements.kind_of?(String) || requirements.nil?
                  raise DebYAMLParseError, "The #{dependency_type} dependency #{name}'s version requirements MUST be either a list of items, or a single item!"
                end
                requirements = [requirements] if requirements.kind_of?(String)
                requirements.collect! { |req| yield(req) } if block_given? && !requirements.nil?
                processed_dependency = {:name => "#{name}#{"-"+ suffix unless suffix.nil?}"}
                processed_dependency[:requirements] = requirements unless requirements.nil?
                processed_dependencies << processed_dependency
              end
            end
          end
          processed_dependencies
        end
      end
      
      class << self
        def resources_dirname
          'data'
        end
        
        def resources_path
          dirs_to_climb_up = Array.new(File.expand_path(File.dirname(__FILE__)).split('/').reverse.index('lib') + 1).collect { '..' }
          File.expand_path(File.join(File.dirname(__FILE__), dirs_to_climb_up, 'resources', self.resources_dirname))
        end
      end
      
      def name
        "name"
      end
      
      def version
        "1.0.0"
      end
      
      def full_name
        "#{name}-#{version}"
      end
      
      def debian_revision
        "1"
      end
      
      def debian_arch
        "all"
      end
      
      def build_system_architecture
        IO.popen('dpkg-architecture -qDEB_BUILD_ARCH').gets.chomp
      end
      
      def architecture_independent?
        debian_arch == 'all'
      end
      
      def dependencies
        [{:name => "dep-name", :requirements => [">= 1.0.0"]}]
      end
      
      def build_dependencies
        [{:name => "dep-name", :requirements => [">= 1.0.0"]}]
      end
      
      def summary
        "Summary description"
      end
      
      def license
        "MIT License text"
      end
      
      def rakefile_location
        [:base_path, 'Rakefile']
      end
      
      def resources_path
        self.class.resources_path
      end
      
      public :binding
    end
  end
end