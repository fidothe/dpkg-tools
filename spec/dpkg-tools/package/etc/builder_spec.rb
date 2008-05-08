require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Etc::Builder, "instances" do
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
    FileUtils.expects(:cp_r).with('/a/path/to/conf-package/etc', '/a/path/to/conf-package/debian/tmp/etc')
    
    @builder.install_package_files
  end
end