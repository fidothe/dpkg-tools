module DpkgTools
  module Package
    module Rails
      class DebYAMLParseError < StandardError; end
      
      class Data
        BASE_GEM_DEPS = [{:name => 'rails-rubygem', :requirements => ['>= 1.2.5-1']},
                         {:name => 'rake-rubygem', :requirements => ['>= 0.7.3-1']}]
        BASE_PACKAGE_DEPS = [{:name => 'mysql-client'}, {:name => 'mysql-server'}]
        
        class << self
          def load_package_data(base_path)
            YAML.load_file(File.join(base_path, 'config/deb.yml')) if File.exist?(File.join(base_path, 'config/deb.yml'))
          end
          
          def process_dependencies(data)
            all_deps = BASE_GEM_DEPS + BASE_PACKAGE_DEPS
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
              unless dependencies[dependency_type].kind_of?(Array) || dependencies[dependency_type].nil?
                raise DebYAMLParseError, "dependencies: #{dependency_type}: is not a list of items!"
              end
              unless dependencies[dependency_type].nil?
                dependencies[dependency_type].each do |dependency|
                  name = dependency.kind_of?(Hash) ? dependency.keys.first : dependency
                  requirements = dependency.kind_of?(Hash) ? dependency.values.first : nil
                  unless requirements.kind_of?(Array) || requirements.kind_of?(String) || requirements.nil?
                    raise DebYAMLParseError, "The #{dependency_type} dependency #{name}'s version requirements MUST be either a list of items, or a single item!"
                  end
                  requirements = [requirements] if requirements.kind_of?(String)
                  requirements.collect! { |req| yield(req) } if block_given?
                  processed_dependencies << {:name => "#{name}#{"-"+ suffix unless suffix.nil?}", :requirements => requirements}
                end
              end
            end
            processed_dependencies
          end
        end
        
        attr_reader :spec, :config
        
        def initialize(base_path)
          @data = self.class.load_package_data(base_path)
          @dependencies = self.class.process_dependencies(@data)
          @config = DpkgTools::Package::Config.new(name, version, :base_path => base_path)
        end
        
        def name
          @data['name']
        end
        
        def version
          @data['version']
        end
        
        def license
          @data['license']
        end
        
        def debian_revision
          "1"
        end
        
        def debian_arch
          "all"
        end
        
        def deb_filename
          @config.deb_filename(debian_arch)
        end
        
        def rakefile_path
          File.join(@config.base_path, 'lib/tasks/dpkg-tools.rake')
        end
        
        def dependencies
          @dependencies
        end
        
        def build_dependencies
          @dependencies
        end
        
        def summary
          @data['summary']
        end
        
        def full_name
          "#{name}-#{version}"
        end
      end
    end
  end
end
