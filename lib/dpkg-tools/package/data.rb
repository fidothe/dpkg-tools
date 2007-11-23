module DpkgTools
  module Package
    class Data
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
        "i386"
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
    end
  end
end