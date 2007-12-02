module DpkgTools
  module Package
    class Data
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