require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Setup, ".from_path" do
  it "should create a DpkgTools::Package::Rails::Data instance, and feed it to .new" do
    DpkgTools::Package::Rails::Setup.expects(:needs_bootstrapping?).with('base_path').returns(false)
    DpkgTools::Package::Rails::Data.expects(:new).with('base_path').returns(:data)
    DpkgTools::Package::Rails::Setup.expects(:new).with(:data, 'base_path').returns(:instance)
    
    DpkgTools::Package::Rails::Setup.from_path('base_path').should == :instance
  end
  
  it "should be able to bootstrap the rails app if needed" do
    DpkgTools::Package::Rails::Setup.expects(:needs_bootstrapping?).with('base_path').returns(true)
    DpkgTools::Package::Rails::Setup.expects(:bootstrap).with('base_path')
    
    DpkgTools::Package::Rails::Data.expects(:new).with('base_path').returns(:data)
    DpkgTools::Package::Rails::Setup.expects(:new).with(:data, 'base_path').returns(:instance)
    
    DpkgTools::Package::Rails::Setup.from_path('base_path').should == :instance
  end
end

describe DpkgTools::Package::Rails::Setup, "bootstrapping" do
  before(:each) do
    DpkgTools::Package::Rails::Data.stubs(:resources_path).returns('/a/path/to/resources')
  end
  
  it "should be able to construct the target file path of a file for bootstrapping" do
    DpkgTools::Package::Rails::Setup.bootstrap_file_path('base_path', 'deb.yml').
      should == 'base_path/config/deb.yml'
  end
  
  it "should be able to report which files are needed for bootstrapping" do
    DpkgTools::Package::Rails::Setup.bootstrap_files.should == ['deb.yml', 'mongrel_cluster.yml']
  end
  
  it ".bootstrap_file should be able to create a needed files" do
    File.stubs(:file?).with('base_path/config/deb.yml').returns(false)
    
    FileUtils.expects(:cp).with('/a/path/to/resources/deb.yml', 'base_path/config/deb.yml')
    
    DpkgTools::Package::Rails::Setup.bootstrap_file('base_path', 'deb.yml')
  end
  
  it ".bootstrap_file should not attempt to create a file that's already there..." do
    File.stubs(:file?).with('base_path/config/deb.yml').returns(true)
    
    FileUtils.expects(:cp).never
    
    DpkgTools::Package::Rails::Setup.bootstrap_file('base_path', 'deb.yml')
  end
  
  it ".bootstrap should copy across the files correctly" do
    DpkgTools::Package::Rails::Setup.expects(:bootstrap_file).with('base_path', 'deb.yml')
    DpkgTools::Package::Rails::Setup.expects(:bootstrap_file).with('base_path', 'mongrel_cluster.yml')
    
    DpkgTools::Package::Rails::Setup.bootstrap('base_path')
  end
end

describe DpkgTools::Package::Rails::Setup, ".needs_bootstrapping?" do
  it ".needs_bootstrapping? should return false if all files are there" do
    File.stubs(:file?).with('base_path/config/deb.yml').returns(true)
    File.stubs(:file?).with('base_path/config/mongrel_cluster.yml').returns(true)
    
    DpkgTools::Package::Rails::Setup.needs_bootstrapping?('base_path').should be(false)
  end
  
  it ".needs_bootstrapping? should return true if one file is missing" do
    File.stubs(:file?).with('base_path/config/deb.yml').returns(false)
    File.stubs(:file?).with('base_path/config/mongrel_cluster.yml').returns(true)
    
    DpkgTools::Package::Rails::Setup.needs_bootstrapping?('base_path').should be(true)
  end
  
  it ".needs_bootstrapping? should return true if both files are missing" do
    File.stubs(:file?).with('base_path/config/deb.yml').returns(false)
    File.stubs(:file?).with('base_path/config/mongrel_cluster.yml').returns(false)
    
    DpkgTools::Package::Rails::Setup.needs_bootstrapping?('base_path').should be(true)
  end
end

describe DpkgTools::Package::Rails::Setup, ".new" do
  before(:each) do
    @data = stub('stub DpkgTools::Package::Rails::Data', :name => 'name', :version => '1', :base_path => 'base_path')
  end
  
  it "should raise an error without any arguments" do
    lambda { DpkgTools::Package::Rails::Setup.new }.should raise_error
  end
  
  it "should require one argument" do
    DpkgTools::Package::Rails::Setup.new(@data)
  end
  
  it "should result in @config being set to a DpkgTools::Package::Config instance" do
    setup = DpkgTools::Package::Rails::Setup.new(@data)
    setup.config.should be_an_instance_of(DpkgTools::Package::Config)
  end
end

describe DpkgTools::Package::Rails::Setup, ".prepare_package" do
  it "should copy the apache conf template across" do
    DpkgTools::Package::Rails::Data.stubs(:resources_path).returns('/a/path/to/resources')
    data = stub('stub DpkgTools::Package::Rails::Data', :name => 'name', :version => '1', :base_path => 'base_path', 
                                                        :resources_path => '/a/path/to/resources')
    config = DpkgTools::Package::Config.new('name', '1', :base_path => 'base_path')
    DpkgTools::Package::Rails::Setup.expects(:bootstrap_file).with('base_path', 'apache.conf.erb')
    DpkgTools::Package::Rails::Setup.expects(:bootstrap_file).with('base_path', 'logrotate.conf.erb')
    
    DpkgTools::Package::Rails::Setup.prepare_package(data, config)
  end
end

describe DpkgTools::Package::Rails::Setup, "instances" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Rails::Data", :name => 'rails-app-name', :version => '1.0.8', 
                 :full_name => 'rails-app-name-1.0.8', :base_path => 'base_path')
    @setup = DpkgTools::Package::Rails::Setup.new(@data)
  end
  
  it "should provide access to the correct options for making a new DpkgTools::Package::Config" do
    @setup.config_options.should == {:base_path => 'base_path'}
  end
  
  it "should provide access to its Package::Rails::Data" do
    @setup.data.should == @data
  end
  
  it "should be able to return the correct list of classes to build control files with" do
    @setup.control_file_classes.should == DpkgTools::Package::Rails::ControlFiles.classes
  end
  
  
  it "should be invoked properly by #prepare_package" do
    DpkgTools::Package::Rails::Setup.expects(:prepare_package).with(@setup.data, @setup.config)
    @setup.prepare_package
  end
end