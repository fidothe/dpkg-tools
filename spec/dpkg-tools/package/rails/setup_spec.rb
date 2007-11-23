require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Setup, ".from_path" do
  it "should create a DpkgTools::Package::Rails::Data instance, and feed it to .new" do
    DpkgTools::Package::Rails::Data.expects(:new).with('base_path').returns(:data)
    DpkgTools::Package::Rails::Setup.expects(:new).with(:data, 'base_path').returns(:instance)
    
    DpkgTools::Package::Rails::Setup.from_path('base_path').should == :instance
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
    @data = stub('stub DpkgTools::Package::Rails::Data', :name => 'name', :version => '1')
  end
  
  it "should raise an error without any arguments" do
    lambda { DpkgTools::Package::Rails::Setup.new }.should raise_error
  end
  
  it "should require two arguments" do
    DpkgTools::Package::Rails::Setup.new(@data, 'base_path')
  end
  
  it "should result in @config being set to a DpkgTools::Package::Config instance" do
    setup = DpkgTools::Package::Rails::Setup.new(@data, 'base_path')
    setup.config.should be_an_instance_of(DpkgTools::Package::Config)
  end
end

describe DpkgTools::Package::Rails::Setup, "instances" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Rails::Data", :name => 'rails-app-name', :version => '1.0.8', 
                 :full_name => 'rails-app-name-1.0.8')
    @setup = DpkgTools::Package::Rails::Setup.new(@data, 'base_path')
  end
  
  it "should provide access to its Package::Rails::Data" do
    @setup.data.should == @data
  end
  
  it "should be able to call DpkgTools::Package::Metadata to write out the debian control files" do
    DpkgTools::Package::Rails::Metadata.expects(:new).with(@setup.data, @setup.config).returns(:metadata)
    DpkgTools::Package::Metadata.expects(:write_control_files).with(:metadata)
    @setup.write_control_files
  end
  
  it "should be able to perform all the steps needed to create the package structure" do
    @setup.stubs(:config).returns(:config)
    
    DpkgTools::Package.expects(:check_package_dir).with(:config)
    
    @setup.expects(:write_control_files)
    
    @setup.create_structure
  end
end