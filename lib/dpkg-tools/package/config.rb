module DpkgTools
  module Package
    class << self
      def config(name_version_pair)
        @config ||= {}
        @config[name_version_pair] ||= DpkgTools::Package::Config.new(*name_version_pair)
        yield(@config[name_version_pair]) if block_given?
        @config[name_version_pair]
      end
    end
    
    class Config
      class << self
        attr_accessor :root_path
      end
      
      attr_accessor :name, :version
      
      def initialize(name, version)
        @name = name
        @version = version
      end
      
      def full_name
        @name + "-" + @version
      end
      
      def package_name
        @name + '-rubygem'
      end
      
      def package_dir_name
        "#{package_name}-#{version}"
      end
      
      def base_path
        File.join(root_path, "#{name}-rubygem-#{version}")
      end
      
      def root_path
        self.class.root_path
      end
      
      def debian_path
        File.join(base_path, 'debian')
      end
      
      def gem_filename
        full_name + '.gem'
      end
      
      def gem_path
        File.join(base_path, gem_filename)
      end
      
      def orig_tarball_path
        base_path + ".orig.tar.gz"
      end
      
      def buildroot
        File.join(debian_path, 'tmp')
      end
      
      def bin_install_path
        File.join(buildroot, 'usr/bin')
      end
      
      def gem_install_path
        File.join(buildroot, 'usr/lib/ruby/gems/1.8')
      end
      
      def buildroot_DEBIAN_path
        File.join(buildroot, 'DEBIAN')
      end
    end
  end
end