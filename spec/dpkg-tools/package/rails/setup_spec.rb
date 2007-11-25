require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Setup, ".from_path" do
  it "should create a DpkgTools::Package::Rails::Data instance, and feed it to .new" do
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

describe DpkgTools::Package::Rails::Setup, "creating config files" do
  it "should be able to return the path to the resources dir, given base_path" do
    File.expects(:dirname).returns('/a/path/to/dpkg-tools/lib/dpkg-tools/package/rails')
    DpkgTools::Package::Rails::Setup.resources_path.should == '/a/path/to/dpkg-tools/resources'
  end
  
  it "should be able to copy across a sample apache.conf.erb file" do
    DpkgTools::Package::Rails::Setup.expects(:resources_path).returns('/a/path/to/resources')
    FileUtils.expects(:cp).with('/a/path/to/resources/apache.conf.erb', 'base_path/config/apache.conf.erb')
    
    DpkgTools::Package::Rails::Setup.create_apache_conf_template('base_path')
  end
  
  it "should be able to copy across a sample deb.yml file" do
    DpkgTools::Package::Rails::Setup.expects(:resources_path).returns('/a/path/to/resources')
    FileUtils.expects(:cp).with('/a/path/to/resources/deb.yml', 'base_path/config/deb.yml')
    
    DpkgTools::Package::Rails::Setup.create_deb_yaml('base_path')
  end
  
  it "should be able to call mongrel_cluster's config creator to create a config.yml for mongrel_cluster" do
    DpkgTools::Package::Rails::Setup.expects(:resources_path).returns('/a/path/to/resources')
    FileUtils.expects(:cp).with('/a/path/to/resources/mongrel_cluster.yml', 'base_path/config/mongrel_cluster.yml')
    
    DpkgTools::Package::Rails::Setup.create_mongrel_cluster_conf_yaml('base_path')
  end
  
  it "should be able to create the base config files" do
    DpkgTools::Package::Rails::Setup.expects(:create_apache_conf_template).with('base_path')
    DpkgTools::Package::Rails::Setup.expects(:create_deb_yaml).with('base_path')
    DpkgTools::Package::Rails::Setup.expects(:create_mongrel_cluster_conf_yaml).with('base_path')
    
    DpkgTools::Package::Rails::Setup.create_config_files('base_path')
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
    data = stub('stub DpkgTools::Package::Rails::Data', :name => 'name', :version => '1', :base_path => 'base_path')
    config = DpkgTools::Package::Config.new('name', '1', :base_path => 'base_path')
    DpkgTools::Package::Rails::Data.stubs(:resources_path).returns('/a/path/to/resources')
    FileUtils.expects(:cp).with('/a/path/to/resources/apache.conf.erb', 'base_path/config/apache.conf.erb')
    
    DpkgTools::Package::Rails::Setup.prepare_package(data, config)
  end
end

describe DpkgTools::Package::Rails::Setup, "instances" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Rails::Data", :name => 'rails-app-name', :version => '1.0.8', 
                 :full_name => 'rails-app-name-1.0.8', :base_path => 'base_path')
    DpkgTools::Package::Rails::Setup.stubs(:prepare_package)
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
end