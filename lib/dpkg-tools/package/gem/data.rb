module DpkgTools
  module Package
    module Gem
      class Data < DpkgTools::Package::Data
        class << self
          def resources_dirname
            'gem'
          end
          
          def process_extensions_map(input_hash)
            output_hash = {}
            input_hash.each do |gem_name, value|
              case value
              when Hash
                output_hash[gem_name] = {}
                value.each do |version_key, deps|
                  version_key = version_key.to_s
                  case deps
                  when Array
                    output_hash[gem_name][version_key] = deps.collect { |dep| {:name => dep} }
                  when String
                    output_hash[gem_name][version_key] = [{:name => deps}]
                  end
                end
              when Array
                output_hash[gem_name] = {'all' => value.collect { |dep| {:name => dep} }}
              when String
                output_hash[gem_name] = {'all' => [{:name => value}]}
              end
            end
            output_hash
          end
          
          def native_extensions_deps_map
            @native_extensions_deps_map ||= process_extensions_map(YAML.load_file(File.join(resources_path, 'gems_to_deps.yml')))
          end
          
          def native_extension_deps(name, version)
            deps_map = native_extensions_deps_map[name]
            return [] if deps_map.nil?
            deps = deps_map[version] 
            deps = deps_map['all'] if deps.nil?
            return [] if deps.nil?
            deps
          end
        end
        
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
          return 'all' if @spec.extensions.empty?
          'i386'
        end
        
        def build_dependencies
          [{:name => "rubygems", :requirements => [">= #{Gem.rubygems_version}-1"]}, 
           {:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]},
           {:name => "dpkg-tools-rubygem", :requirements => [">= #{DpkgTools::VERSION::STRING}-1"]}] \
            + base_deps \
            + self.class.native_extension_deps(name, version)
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