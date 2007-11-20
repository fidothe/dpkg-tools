module DpkgTools
  module Package
    module Gem
      class Data
        attr_reader :spec, :config
        
        def initialize(format)
          @format = format
          @spec = format.spec
          
          @config = DpkgTools::Package::Config.new(name, version, :suffix => "rubygem")
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
        
        def files
          @spec.files
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
          @config.deb_filename(debian_arch)
        end
        
        def dependencies
          @spec.dependencies
        end
        
        def summary
          @spec.summary
        end
        
        def rakefile_path
          File.join(@config.base_path, 'Rakefile')
        end
      end
    end
  end
end