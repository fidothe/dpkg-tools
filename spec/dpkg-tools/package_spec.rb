require File.dirname(__FILE__) + '/../spec_helper'

describe DpkgTools::Package, ".check_package_dir" do
  before(:each) do
    DpkgTools::Package::Config.root_path = "a/path/to/"
    @config = DpkgTools::Package::Config.new('stub-gem', '1.0.1')
  end
  
  it "should be able to check that the package dir exists and make it otherwise" do
    File.expects(:directory?).with('a/path/to/stub-gem-1.0.1').returns(false)
    Dir.expects(:mkdir).with('a/path/to/stub-gem-1.0.1')
    DpkgTools::Package.check_package_dir(@config)
  end
  
  it "should be able to check the package dir exists and not attempt to make it if it is already there" do
    File.expects(:directory?).with('a/path/to/stub-gem-1.0.1').returns(true)
    Dir.expects(:mkdir).never
    DpkgTools::Package.check_package_dir(@config)
  end
end

describe DpkgTools::Package, ".create_gem_structure" do
  it "should do the appropriate things" do
    DpkgTools::Package::Gem.expects(:create_structure).with('gem_name')
    
    DpkgTools::Package.create_gem_structure('gem_name')
  end
end

describe DpkgTools::Package, ".standards_version" do
  it "should be able to return the current Debian standards version we're generating control files against" do
    DpkgTools::Package.standards_version.should == "3.7.2"
  end
end