require 'optparse'
require 'dpkg-tools'

module DpkgTools
  module CommandLine
    module Rails
      class << self
        def run(args, err, out)
          options = {}
          opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: dpkg-rails [options] PATH_TO_RAILS_APP"
            
            opts.separator ""
            opts.separator "Common options:"
            
            opts.on_tail("-h", "--help", "Show this message") do
              err.puts opts
              exit
            end
            
            # Another typical switch to print the version.
            opts.on_tail("--version", "Show version") do
              err.puts DpkgTools::Version.STRING
              exit
            end
          end
          opt_parser.parse!(args)
          
          begin
            app_path = args.first
            raise ArgumentError, "You must supply a valid path to a rails app - #{app_path} doesn't exist!" unless File.exist?(app_path)
            
            DpkgTools::Package::Rails.setup_from_path(app_path)
          rescue ArgumentError => e
            err.puts opt_parser
            err.puts ""
            err.puts e
          end
        end
      end
    end
    
    module Etc
      class << self
        def run(args, err, out)
          options = {}
          opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: dpkg-etc [options] PATH_TO_CONF_PACKAGE"
            
            opts.separator ""
            opts.separator "Common options:"
            
            opts.on_tail("-h", "--help", "Show this message") do
              err.puts opts
              exit
            end
            
            # Another typical switch to print the version.
            opts.on_tail("--version", "Show version") do
              err.puts DpkgTools::Version.STRING
              exit
            end
          end
          opt_parser.parse!(args)
          
          begin
            package_path = args.first
            package_parent_path = File.dirname(package_path)
            raise ArgumentError, "You must supply a valid path to a package - #{package_parent_path} doesn't exist!" unless File.exist?(package_parent_path)
            
            DpkgTools::Package::Etc.setup_from_path(package_path)
          rescue ArgumentError => e
            err.puts opt_parser
            err.puts ""
            err.puts e
          end
        end
      end
    end
    
    module Gem
      class << self
        def run(args, err, out)
          options = {}
          opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: dpkg-gem [options] GEM-NAME"

            opts.separator ""
            opts.separator "Specific options:"

            opts.on("-f", "--from-gem", "Take the GEM-NAME argument as the path",
                                        "to a .gem and create package from that",
                                        "rather than looking remotely.",
                                        "Implies --ignore-dependencies.") do |from_path|
              options[:from_path] = from_path
              options[:ignore_dependencies] = true
            end

            opts.on("-f", "--ignore-dependencies", "Don't fetch and create packages for dependencies.") do
              options[:ignore_dependencies] = true
            end

            opts.separator ""
            opts.separator "Common options:"

            opts.on_tail("-h", "--help", "Show this message") do
              err.puts opts
              exit
            end

            # Another typical switch to print the version.
            opts.on_tail("--version", "Show version") do
              err.puts DpkgTools::Version.STRING
              exit
            end
          end
          opt_parser.parse!(args)

          DpkgTools::Package::Config.root_path = File.expand_path('./')

          begin
            if options[:from_path]
              raise ArgumentError, "You must supply the path to a valid gem file!" unless args.size > 0
              gem_path = args.first
              raise ArgumentError, "You must supply the path to a valid gem file - #{gem_path} doesn't exist!" unless File.exist?(gem_path)
              raise ArgumentError, "You must supply the path to a valid gem file - #{gem_path} is a directory!" unless File.file?(gem_path)

              DpkgTools::Package::Gem.setup_from_path(gem_path, options)
            else
              raise ArgumentError, "You must supply the name of a gem!" unless args.size > 0
              DpkgTools::Package::Gem.setup_from_name(args.first, options)
            end
          rescue ArgumentError => e
            err.puts opt_parser
            err.puts ""
            err.puts e
          end
        end
      end
    end
  end
end