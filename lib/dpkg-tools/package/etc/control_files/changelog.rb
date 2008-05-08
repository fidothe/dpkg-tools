require 'time'

module DpkgTools
  module Package
    module Etc
      module ControlFiles
        class Changelog < DpkgTools::Package::ControlFiles::Changelog
          def changelog
            changelog_yaml = YAML::load_file(config.base_path + '/changelog.yml')
            changelog_entries = []
            changelog_yaml.each do |change|
              change_lines = [] 
              change_lines << "#{config.package_name} (#{change['version']}-1) cp-gutsy; urgency=low"
              change['changes'].each do |lines|
                lines = lines.split("\n")
                # first line is different to the others
                change_lines << "  * " + lines.shift
                lines.each { |line| change_lines << "    " + line }
              end
              change_lines << " -- Matt Patterson <matt@reprocessed.org>  #{Time.xmlschema(change['date']).rfc822}"
              changelog_entries << change_lines.join("\n")
            end
            changelog_entries << "" # for that final newline
            changelog_entries.join("\n")
          end
        end
      end
    end
  end
end