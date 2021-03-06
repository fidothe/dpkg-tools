require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Etc::Builder do
  describe ".from_path support" do
    it "should return DpkgTools::Package::Etc::Data when asked for the data subclass to use" do
      DpkgTools::Package::Etc::Builder.data_class.should == DpkgTools::Package::Etc::Data
    end
  end
  
  describe "instances" do
    before(:each) do
      @config = DpkgTools::Package::Config.new('rails-app', '1.0.8')
      DpkgTools::Package::Etc::Data.expects(:load_package_data).with('/a/path/to/conf-package', 'deb.yml').
        returns({'name' => 'conf-package', 'version' => '1.0.8'})
      @data = DpkgTools::Package::Etc::Data.new('/a/path/to/conf-package')
    
      @builder = DpkgTools::Package::Etc::Builder.new(@data)
    end
  
    it "should provide the correct options for DpkgTools::Package::Config " do
      @builder.config_options.should == {:base_path => "/a/path/to/conf-package"}
    end
  
    it "should be able to create the needed install dirs" do
      @builder.expects(:create_dir_if_needed).with('/a/path/to/conf-package/debian/tmp/etc')
    
      @builder.create_install_dirs
    end
  
    it "should copy the contents of package/etc to package/debian/tmp/etc/" do
      Dir.expects(:[]).with('/a/path/to/conf-package/etc/**/*').returns(['/a/path/to/conf-package/etc/thing',
                                                                         '/a/path/to/conf-package/etc/thing/conf_file',
                                                                         '/a/path/to/conf-package/etc/thing/wotsit.yml'])
      File.expects(:file?).with('/a/path/to/conf-package/etc/thing').returns(false)
      File.expects(:file?).with('/a/path/to/conf-package/etc/thing/conf_file').returns(true)
      FileUtils.expects(:mkdir_p).with('/a/path/to/conf-package/debian/tmp/etc/thing')
      FileUtils.expects(:install).with('/a/path/to/conf-package/etc/thing/conf_file',
                                       '/a/path/to/conf-package/debian/tmp/etc/thing/conf_file',
                                       {:mode => 0644, :verbose => true})
      File.expects(:file?).with('/a/path/to/conf-package/etc/thing/wotsit.yml').returns(true)
      FileUtils.expects(:mkdir_p).with('/a/path/to/conf-package/debian/tmp/etc/thing')
      FileUtils.expects(:install).with('/a/path/to/conf-package/etc/thing/wotsit.yml',
                                       '/a/path/to/conf-package/debian/tmp/etc/thing/wotsit.yml',
                                       {:mode => 0644, :verbose => true})
      @builder.install_package_files
    end
  end
end