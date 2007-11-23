module DpkgTools
  module Package
    module ControlFiles
      class Control < DpkgTools::Package::ControlFiles::Base
        class << self
          def filename
            'control'
          end
          
          def formatter_class
            ControlFormatter
          end
        end
      end
      
      class ControlFormatter < DpkgTools::Package::ControlFiles::BaseFormatter
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
           define_method(field_name) {depends_line(field_name)}
        end
        
        # generate the Maintainer line
        def maintainer
          "Maintainer: #{metadata.maintainer[0]} <#{metadata.maintainer[1]}>"
        end
        
        def build
          @output = []
          # Source 'paragraph'
          source_field_names.each {|field_name| process_field(field_name)}
          
          # line break to make new debian/control 'paragraph'
          output << "" 
          
          # Binary 'paragraph'
          binary_field_names.each {|field_name| process_field(field_name)}
          
          # required final newline
          output << ""
          output.join("\n")
        end
        
        private
        
        def process_field(field_name)
          if metadata.respond_to?(field_name)
            if self.respond_to?(field_name)
              output << self.send(field_name)
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
        
        def depends_line(field_name)
          "#{field_names_map[field_name]}: #{deps_string(metadata.send(field_name))}"
        end
      end
    end
  end
end