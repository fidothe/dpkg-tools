module DpkgTools
  module Package
    module Rails
      class DebYAMLParseError < StandardError; end
      
      class Data < DpkgTools::Package::Data
        BASE_GEM_DEPS = [{:name => 'rails-rubygem', :requirements => ['>= 1.2.5-1']},
                         {:name => 'rake-rubygem', :requirements => ['>= 0.7.3-1']},
                         {:name => 'mysql-rubygem', :requirements => ['>= 2.7-1']},
                         {:name => 'mongrel-cluster-rubygem', :requirements => ['>= 1.0.1-1']}]
        BASE_PACKAGE_DEPS = [{:name => 'mysql-client'}, {:name => 'mysql-server'}, {:name => 'apache2'}]
        
        class << self
          def load_package_data(base_path, filename)
            YAML.load_file(File.join(base_path, 'config', filename)) if File.exist?(File.join(base_path, 'config', filename))
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
          
          def resources_dirname
            'rails'
          end
        end
        
        attr_reader :spec, :config, :base_path, :database_configurations
        
        def initialize(base_path)
          @data = self.class.load_package_data(base_path, 'deb.yml')
          @mongrel_cluster_data = @data['mongrel_cluster']
          @database_configurations = self.class.load_package_data(base_path, 'database.yml')
          
          @dependencies = self.class.process_dependencies(@data)
          @base_path = base_path
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
        
        def rakefile_location
          [:base_path, 'lib/tasks/dpkg-tools.rake']
        end
        
        def mongrel_cluster_config_hash
          @mongrel_cluster_data
        end
        
        def number_of_mongrels
          @mongrel_cluster_data['servers']
        end
        
        def mongrel_cluster_start_port
          @mongrel_cluster_data['port']
        end
        
        def mongrel_ports
          Array.new(number_of_mongrels) {|i| (mongrel_cluster_start_port.to_i + i).to_s}
        end
        
        def init_name
          @data['init_name']
        end
        
        def app_install_path
          "/var/lib/#{name}"
        end
        
        def pidfile_dir_path
          "/var/run/#{name}"
        end
        
        def logfile_path
          "/var/log/#{name}"
        end
        
        def conf_dir_path
          "/etc/#{name}"
        end
        
        def init_script_path
          "/etc/init.d/#{name}"
        end
        
        def dot_ssh_path
          "#{app_install_path}/.ssh"
        end
        
        def authorized_keys_path
          "#{dot_ssh_path}/authorized_keys"
        end
        
        def username
          name
        end
        
        def user
          name
        end
        
        def server_name
          @data['server_name']
        end
        
        def server_aliases
          @data['server_aliases']
        end
        
        def application
          name
        end
        
        def deploy_to
          app_install_path
        end
        
        def deployers_ssh_keys_dir
          File.join(base_path, 'config/deployers_ssh_keys')
        end
      end
    end
  end
end
