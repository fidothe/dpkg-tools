module DpkgTools
  module Package
    module Gem
      class Data
        attr_reader :spec
        
        def initialize(format)
          @format = format
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
        
        def config_key
          [self.name, self.version]
        end
        
        def file_entries
          @format.file_entries
        end
        
        def debian_revision
          "1"
        end
        
        def debian_arch
          "i386"
        end
        
        def deb_filename
          "#{name}-rubygem-#{version}-#{debian_revision}_#{debian_arch}.deb"
        end
        
        def dependencies
          @spec.dependencies
        end
      end
    end
  end
end