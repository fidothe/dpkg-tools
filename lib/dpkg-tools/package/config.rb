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
      
      attr_reader :name, :version
      
      def initialize(name, version, options = {})
        @name = name
        @version = version
        @options = options
      end
      
      def full_name
        @name + "-" + @version
      end
      
      def package_name
        @name.downcase.tr("_", "-") + (@options[:suffix].nil? ? '' : "-#{@options[:suffix]}")
      end
      
      def package_dir_name
        File.basename(base_path)
      end
      
      def base_path
        return @options[:base_path] if @options.has_key?(:base_path)
        File.join(root_path, "#{package_name}-#{version}")
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
      
      def etc_install_path
        File.join(buildroot, 'etc')
      end
      
      def buildroot_DEBIAN_path
        File.join(buildroot, 'DEBIAN')
      end
      
      def deb_filename(deb_arch)
        "#{package_name}_#{deb_version}_#{deb_arch}.deb"
      end
      
      def deb_version
        "#{version}-1"
      end
    end
  end
end