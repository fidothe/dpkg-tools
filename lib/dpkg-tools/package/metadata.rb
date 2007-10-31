module DpkgTools
  module Package
    module Metadata
      class << self
        def write_control_files(gem)
          Control.generate(gem)
          Copyright.generate(gem)
          Changelog.generate(gem)
          Rules.generate(gem)
          Rakefile.generate(gem)
        end
      end
      
      class Base
        class << self
          def file_path(gem)
            File.join(DpkgTools::Package.config(gem.config_key).send(parent_path), filename)            
          end
          
          def parent_path
            :debian_path
          end
          
          def write(gem, file_contents)
            Files.write(self.file_path(gem), file_contents)
          end
          
          def generate(gem)
            self.write(gem, self.build(gem))
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
          
          def build(gem)
            # Read metadata
            control_file = []
            # Source (mandatory)
            control_file << "Source: #{gem.name}-rubygem"
            # Maintainer (mandatory)
            control_file << "Maintainer: Matt Patterson <matt@reprocessed.org>"
            # Uploaders - n/a
            # Section (recommended)
            control_file << "Section: libs"
            # Priority (recommended)
            control_file << "Priority: optional"
            # Build-Depends et al
            build_deps = ["rubygems (>= 0.9.4)", "rake-rubygem (>= 0.7.0)"]
            gem.spec.dependencies.each do |dependency|
              entry = ["#{dependency.name}-rubygem"]
              dependency.version_requirements.as_list.each do |version|
                entry << "(#{version})"
              end
              build_deps << entry.join(' ')
            end
            control_file << "Build-Depends: #{build_deps.join(', ')}" unless build_deps.empty?
            # Standards-Version (recommended)

            # The fields in the binary package paragraphs are:
            control_file << "" # line break to make new debian/control 'paragraph'
            # Package (mandatory)
            control_file << "Package: #{gem.name}-rubygem"
            # Architecture (mandatory)
            control_file << "Architecture: i386"
            # Section (recommended)
            control_file << "Section: libs"
            # Priority (recommended)
            control_file << "Priority: optional"
            # Essential
            control_file << "Essential: no"
            # Depends et al
            deps = []
            gem.spec.dependencies.each do |dependency|
              entry = ["#{dependency.name}-rubygem"]
              dependency.version_requirements.as_list.each do |version|
                entry << "(#{version})"
              end
              deps << entry.join(' ')
            end
            control_file << "Depends: #{build_deps.join(', ')}" unless build_deps.empty?
            control_file << "Pre-Depends: rubygems (>> 0.9.0)"
            # Description (mandatory)
            control_file << "Description: #{gem.spec.summary}" # NB, currently really fudged (not using the proper description)
            # for the final newline
            control_file << ""
            control_file.join("\n")
          end
        end
      end
      
      class Copyright < Base
        class << self
          def filename
            'copyright'
          end
          
          # build debian/copyright file
          def build(gem)
            # first, look for LICENSE or MIT-LICENSE in the gem
            licenses = gem.spec.files.select do |file_path|
              file_path.match(/license/i)
            end

            if licenses.size == 1
              license_path = licenses.first
              license_files = gem.file_entries.select do |meta, data|
                meta["path"] == license_path
              end
              license_files.first[1]
            end
          end
        end
      end
      
      class Changelog < Base
        class << self
          def filename
            'changelog'
          end
          
          # build debian/changelog file
          def build(gem)
            "#{gem.name}-rubygem (#{gem.version}-1) cp-gutsy; urgency=low\n"\
            "  * Packaged up #{gem.full_name}\n"\
            " -- Matt Patterson <matt@reprocessed.org>  #{Time.now.rfc822}\n"
          end
        end
      end
      
      class Rules < Base
        class << self
          def filename
            'rules'
          end
          
          def build(gem)
            "#!/bin/sh\n" \
            "\n" \
            "/usr/bin/rake $@\n" \
          end
          
          def write(gem, file_contents)
            Files.write_executable(self.file_path(gem), file_contents)
          end
        end
      end
      
      class Rakefile < Base
        class << self
          def filename
            'Rakefile'
          end
          
          def parent_path
            :base_path
          end
          
          def build(gem)
            conf = DpkgTools::Package.config(gem.config_key)
            "require 'rubygems'\n" \
            "require 'dpkg-tools'\n" \
            "\n" \
            "DpkgTools::Package::Gem::BuildTasks.new do |t|\n" \
            "  t.root_path = File.expand_path('../')\n" \
            "  t.gem_path = File.expand_path('./#{conf.gem_filename}')\n" \
            "end\n" \
          end
          
          def write(gem, file_contents)
            Files.write_executable(self.file_path(gem), file_contents)
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