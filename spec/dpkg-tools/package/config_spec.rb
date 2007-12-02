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
  
  it "should allow base_path to be specified as well as name and version" do
    DpkgTools::Package::Config.new('gem_name', '1.0.8', {:base_path => '/a/path/to'}).
      should be_an_instance_of(DpkgTools::Package::Config)
  end
end

describe DpkgTools::Package::Config, "instances" do
  before(:each) do
    DpkgTools::Package::Config.root_path = "a/path"
    @config = DpkgTools::Package::Config.new('gemname', '1.0.8', {:suffix => "rubygem"})
  end
  
  it "should be able to set and return the path to the base package dir" do
    @config.base_path.should == "a/path/gemname-rubygem-1.0.8"
  end
  
  it "should be able to return the path to the debian dir in the package" do
    @config.debian_path.should == "a/path/gemname-rubygem-1.0.8/debian"
  end
  
  it "should be able to return the path to the .gem with #base_path" do
    @config.gem_path.should == "a/path/gemname-rubygem-1.0.8/gemname-1.0.8.gem"
  end
  
  it "should be able to return the root_path set on the class" do
    DpkgTools::Package::Config.root_path = 'a/root/path'
    @config.root_path.should == 'a/root/path'
  end
  
  it "should be able to return the file name of the gem" do
    @config.gem_filename.should == 'gemname-1.0.8.gem'
  end
  
  it "should be able to return the name of the dpkg package dir" do
    @config.package_dir_name.should == 'gemname-rubygem-1.0.8'
  end
  
  it "should be able to return the name of the dpkg package name of the gem" do
    @config.package_name.should == 'gemname-rubygem'
  end
  
  it "should be able to return the path to where the .orig.tar.gz file should be" do
    @config.orig_tarball_path.should == "a/path/gemname-rubygem-1.0.8.orig.tar.gz"
  end
  
  it "should be able to return the path to where the package buildroot should be" do
    @config.intermediate_buildroot.should == "a/path/gemname-rubygem-1.0.8/dpkg-tools-tmp"
  end
  
  it "should be able to return the path to where the package intermediate buildroot should be" do
    @config.buildroot.should == "a/path/gemname-rubygem-1.0.8/debian/tmp"
  end
  
  it "should be able to return the path to where the bin dir in the buildroot should be" do
    @config.bin_install_path.should == "a/path/gemname-rubygem-1.0.8/debian/tmp/usr/bin"
  end
  
  it "should be able to return the path to where the gem install dir in the package buildroot should be" do
    @config.gem_install_path.should == "a/path/gemname-rubygem-1.0.8/debian/tmp/usr/lib/ruby/gems/1.8"
  end
  
  it "should be able to return the path to where the etc dir in the package buildroot should be" do
    @config.etc_install_path.should == "a/path/gemname-rubygem-1.0.8/debian/tmp/etc"
  end
  
  it "should be able to return the path to the DEBIAN control dir of the buildroot" do
    @config.buildroot_DEBIAN_path.should == "a/path/gemname-rubygem-1.0.8/debian/tmp/DEBIAN"
  end
  
  it "should provide access to the filename the built .deb will have" do
    @config.deb_filename("1", "i386").should == "gemname-rubygem_1.0.8-1_i386.deb"
  end
  
  it "should provide access to the version" do
    @config.version.should == "1.0.8"
  end
  
  it "should provide access to the debianized version (with package release suffix)" do
    @config.deb_version("1").should == "1.0.8-1"
  end
end

describe DpkgTools::Package::Config, "instances with suffix specified directly" do
  before(:each) do
    DpkgTools::Package::Config.root_path = "a/path"
  end
  
  it "should be able to cope with 'rubygem' suffix" do
    config = DpkgTools::Package::Config.new('package-name', '1.0.8', :suffix => "rubygem")
    config.package_name.should == 'package-name-rubygem'
  end
  
  it "should be able to cope with non-'rubygem' suffix" do
    config = DpkgTools::Package::Config.new('package-name', '1.0.8', :suffix => "fnordling")
    config.package_name.should == 'package-name-fnordling'
  end
end

describe DpkgTools::Package::Config, "instances for gem names with debian oddities" do
  before(:each) do
    DpkgTools::Package::Config.root_path = "a/path"
  end
  
  it "should be able to cope with gem names with underscores in them" do
    config = DpkgTools::Package::Config.new('gem_name', '1.0.8', :suffix => "rubygem")
    config.package_name.should == 'gem-name-rubygem'
  end
  
  it "should be able to cope with gem names with capitalisation in them" do
    config = DpkgTools::Package::Config.new('BlueCloth', '1.0.8', :suffix => "rubygem")
    config.package_name.should == 'bluecloth-rubygem'
  end
end

describe DpkgTools::Package::Config, "instances with base_path specified directly" do
  before(:each) do
    @config = DpkgTools::Package::Config.new('package-name', '1.0.8', :base_path => '/a/path/to/package-name')
  end
  
  it "should be able to set and return the path to the base package dir" do
    @config.base_path.should == "/a/path/to/package-name"
  end
  
  it "should be able to return the name of the dpkg package dir" do
    @config.package_dir_name.should == 'package-name'
  end
  
  it "should be able to return the correct root_path" do
    @config.root_path.should == '/a/path/to'
  end
end