module DpkgTools
  module Package
    module Metadata
      class << self
        def write_control_files(metadata)
          Control.generate(metadata)
          Copyright.generate(metadata)
          Changelog.generate(metadata)
          Rules.generate(metadata)
          Rakefile.generate(metadata)
        end
      end
      
      class Base
        class << self
          def file_path(metadata)
            File.join(metadata.debian_path, filename)            
          end
          
          def write(metadata, file_contents)
            Files.write(self.file_path(metadata), file_contents)
          end
          
          def generate(metadata)
            self.write(metadata, self.build(metadata))
          end
        end
      end
        
      class Control < Base
        class << self
          def filename
            'control'
          end
          
          def source_field_names
            [:source, :maintainer, :uploaders, :section, :priority, 
             :build_depends, :build_depends_indep, :build_conflicts, 
             :build_conflicts_indep, :standards_version]
          end
          
          def binary_field_names
            [:package, :architecture, :section, :priority, :essential, 
             :depends, :recommends, :suggests, :enhances, :pre_depends, 
             :description]
          end
          
          def field_names_map
            {:source => "Source", :maintainer => "Maintainer", :uploaders => "Uploaders", 
             :section => "Section", :priority => "Priority", :build_depends => "Build-Depends", 
             :build_depends_indep => "Build-Depends-Indep", :build_conflicts => "Build-Conflicts", 
             :build_conflicts_indep => "Build-Conflicts-Indep", :standards_version => "Standards-Version", 
             :package => "Package", :architecture => "Architecture", :essential => "Essential", 
             :depends => "Depends", :recommends => "Recommends", :suggests => "Suggests", 
             :enhances => "Enhances", :pre_depends => "Pre-Depends", :description => "Description"}
          end
          
          # Dynamically define methods to handle dependency lines (they're all the same bar the name...)
          [:build_depends, :build_depends_indep, :build_conflicts, :build_conflicts_indep, 
           :depends, :recommends, :suggests, :enhances, :pre_depends].each do |field_name|
             define_method(field_name) {|metadata| depends_line(field_name, metadata)}
          end
          
          # generate the Maintainer line
          def maintainer(metadata)
            "Maintainer: #{metadata.maintainer[0]} <#{metadata.maintainer[1]}>"
          end
          
          def build(metadata)
            lines = []
            # Source 'paragraph'
            source_field_names.each {|field_name| process_field(field_name, metadata, lines)}
            
            # line break to make new debian/control 'paragraph'
            lines << "" 
            
            # Binary 'paragraph'
            binary_field_names.each {|field_name| process_field(field_name, metadata, lines)}
            
            # required final newline
            lines << ""
            lines.join("\n")
          end
          
          private
          
          def process_field(field_name, metadata, output)
            if metadata.respond_to?(field_name)
              if self.respond_to?(field_name)
                output << self.send(field_name, metadata)
              else
                output << "#{field_names_map[field_name]}: #{metadata.send(field_name)}"
              end
            end
          end
          
          def deps_string(dependencies)
            deps = []
            dependencies.each do |dependency|
              reqs = dependency.has_key?(:requirements) ? dependency[:requirements].collect {|req| "(#{req})"} : []
              deps << ([dependency[:name]] + reqs).join(" ")
            end
            deps.join(", ")
          end
          
          def depends_line(field_name, metadata)
            "#{field_names_map[field_name]}: #{deps_string(metadata.send(field_name))}"
          end
        end
      end
      
      class Copyright < Base
        class << self
          def filename
            'copyright'
          end
          
          # build debian/copyright file
          def build(metadata)
            metadata.license_file
          end
        end
      end
      
      class Changelog < Base
        class << self
          def filename
            'changelog'
          end
          
          # build debian/changelog file
          def build(metadata)
            metadata.changelog
          end
        end
      end
      
      class Rules < Base
        class << self
          def filename
            'rules'
          end
          
          def build(metadata)
            "#!/bin/sh\n" \
            "\n" \
            "/usr/bin/rake $@\n" \
          end
          
          def write(metadata, file_contents)
            Files.write_executable(self.file_path(metadata), file_contents)
          end
        end
      end
      
      class Rakefile < Base
        class << self
          def file_path(metadata)
            metadata.rakefile_path
          end
          
          def build(metadata)
            metadata.rakefile
          end
          
          def write(metadata, file_contents)
            Files.write_executable(self.file_path(metadata), file_contents)
          end
        end
      end
      
      class MaintainerScripts
        class << self
          def process(script_name, metadata)
            
          end
          
          def generate(metadata)
            metadata.maintainer_scripts.each {|script_name| process(script_name, metadata)}
          end
        end
      end
      
      module Files
        class << self
          def check_debian_dir(debian_path)
            Dir.mkdir(debian_path) unless File.exists?(debian_path)
          end
          
          def write(file_path, contents)
            check_debian_dir(File.dirname(file_path))
            File.open(file_path, 'w') do |f|
              f.write(contents)
            end
          end
          
          def write_executable(file_path, contents)
            self.write(file_path, contents)
            File.chmod(0755, file_path)
          end
        end
      end
    end
  end
end