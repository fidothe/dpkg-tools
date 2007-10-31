require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Config do
  it "should be able to set and return the root dir in which all package making is happening" do
    DpkgTools::Package::Config.root_path = "a/path"
    DpkgTools::Package::Config.root_path.should == "a/path"
  end
end

describe DpkgTools::Package::Config, ".new" do
  it "should require a name, version pair of arguments" do
    DpkgTools::Package::Config.new('gem_name', '1.0.8').
      should be_an_instance_of(DpkgTools::Package::Config)
  end
  
  it "should throw an error if the argument is not present" do
    lambda { DpkgTools::Package::Config.new() }.should raise_error
  end
end

describe DpkgTools::Package, ".config method" do
  it "should create and return a DpkgTools::Package::Config instance corresponding to the given full name key" do
    DpkgTools::Package.config(['gem_name', '1.0.8']).should be_an_instance_of(DpkgTools::Package::Config)
  end
  
  it "should only create and return a single DpkgTools::Package::Config instance" do
    DpkgTools::Package.config(['gem_name', '1.0.8']).should === DpkgTools::Package.config(['gem_name', '1.0.8'])
  end
  
  it "should yield the Config instance if passed a block" do
    result = nil
    DpkgTools::Package.config(['gem_name', '1.0.8']) {|cfg| result = cfg}
    result.should == DpkgTools::Package.config(['gem_name', '1.0.8'])
  end
end

describe DpkgTools::Package::Config, "instances" do
  before(:each) do
    DpkgTools::Package::Config.root_path = "a/path"
    @config = DpkgTools::Package::Config.new('gem_name', '1.0.8')
  end
  
  it "should be able to set and return the path to the base package dir" do
    @config.base_path.should == "a/path/gem_name-rubygem-1.0.8"
  end
  
  it "should be able to return the path to the debian dir in the package" do
    @config.debian_path.should == "a/path/gem_name-rubygem-1.0.8/debian"
  end
  
  it "should be able to return the path to the .gem with #base_path" do
    @config.gem_path.should == "a/path/gem_name-rubygem-1.0.8/gem_name-1.0.8.gem"
  end
  
  it "should be able to return the root_path set on the class" do
    DpkgTools::Package::Config.root_path = 'a/root/path'
    @config.root_path.should == 'a/root/path'
  end
  
  it "should be able to return the file name of the gem" do
    @config.gem_filename.should == 'gem_name-1.0.8.gem'
  end
  
  it "should be able to return the name of the dpkg package dir" do
    @config.package_dir_name.should == 'gem_name-rubygem-1.0.8'
  end
  
  it "should be able to return the name of the dpkg package name of the gem" do
    @config.package_name.should == 'gem_name-rubygem'
  end
  
  it "should be able to return the path to where the .orig.tar.gz file should be" do
    @config.orig_tarball_path.should == "a/path/gem_name-rubygem-1.0.8.orig.tar.gz"
  end
  
  it "should be able to return the path to where the package buildroot should be" do
    @config.buildroot.should == "a/path/gem_name-rubygem-1.0.8/debian/tmp"
  end
  
  it "should be able to return the path to where the bin dir in the buildroot should be" do
    @config.bin_install_path.should == "a/path/gem_name-rubygem-1.0.8/debian/tmp/usr/bin"
  end
  
  it "should be able to return the path to where the gem install dir in the package buildroot should be" do
    @config.gem_install_path.should == "a/path/gem_name-rubygem-1.0.8/debian/tmp/usr/lib/ruby/gems/1.8"
  end
  
  it "should be able to return the path to the DEBIAN control dir of the buildroot" do
    @config.buildroot_DEBIAN_path.should == "a/path/gem_name-rubygem-1.0.8/debian/tmp/DEBIAN"
  end
end
