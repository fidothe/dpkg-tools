module DpkgTools
  module Package
    module ControlFiles
      class Base
        class << self
          def check_target_dir(target_dir_path)
            Dir.mkdir(target_dir_path) unless File.exists?(target_dir_path)
          end
          
          def write(file_path, contents)
            check_target_dir(File.dirname(file_path))
            File.open(file_path, 'w') do |f|
              f.write(contents)
            end
          end
          
          def write_executable(file_path, contents)
            self.write(file_path, contents)
            File.chmod(0755, file_path)
          end
          
          def filename
            'base'
          end
          
          def formatter_class
            BaseFormatter
          end
        end
        
        attr_reader :data, :config, :formatter
        
        def initialize(data, config)
          @data = data
          @config = config
          @formatter = self.class.formatter_class.new(self)
        end
        
        def executable?
          false
        end
        
        def filename
          self.class.filename
        end
        
        def file_path
          File.join(@config.debian_path, filename)
        end
        
        def to_s
          formatter.build
        end
        
        def write
          write_method = executable? ? :write_executable : :write
          self.class.send(write_method, file_path, self.to_s)
        end
        
        def needs_reset?
          return true unless File.exist?(file_path)
          File.read(file_path) != self.to_s
        end
      end
      
      class BaseFormatter
        attr_reader :metadata, :output
        
        def initialize(metadata)
          @metadata = metadata
        end
      end
    end
  end
end
