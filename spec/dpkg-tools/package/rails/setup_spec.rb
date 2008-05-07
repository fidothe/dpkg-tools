require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Setup, ".from_path" do
  it "should return the correct class from .data_class" do
    DpkgTools::Package::Rails::Setup.data_class.should == DpkgTools::Package::Rails::Data
  end
  
  it "should create a DpkgTools::Package::Rails::Data instance, and feed it to .new" do
    DpkgTools::Package::Rails::Setup.stubs(:needs_bootstrapping?).returns(false)
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
    DpkgTools::Package::Rails::Setup.bootstrap_files.should == ['deb.yml']
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

describe DpkgTools::Package::Rails::Setup do
  before(:each) do
    @data = stub('stub DpkgTools::Package::Rails::Data', :name => 'name', :version => '1', :base_path => 'base_path', 
                                                        :resources_path => '/a/path/to/resources',
                                                        :app_install_path => '/var/lib/name',
                                                        :pidfile_dir_path => '/var/run/name',
                                                        :mongrel_cluster_config_hash => {'port' => "8000",
                                                          'environment' => 'production',
                                                          'address' => '127.0.0.1',
                                                          'servers' => 3})
    @data.stubs(:deployers_ssh_keys_dir).returns('deployers_ssh_keys')
    @config = DpkgTools::Package::Config.new('name', '1', :base_path => 'base_path')
  end
  
  it "should be able to provide a list of the resource files to be copied across during setup" do
    DpkgTools::Package::Rails::Setup.resource_file_names.
      should == ['apache.conf.erb', 'logrotate.conf.erb', 'mongrel_cluster_init.erb', 'deploy.rb']
  end
  
  it ".prepare_package should copy the conf templates and extra structures across" do
    DpkgTools::Package::Rails::Setup.stubs(:resource_file_names).returns(['apache.conf.erb'])
    DpkgTools::Package::Rails::Data.stubs(:resources_path).returns('/a/path/to/resources')
    data = stub('stub DpkgTools::Package::Rails::Data', :name => 'name', :version => '1', :base_path => 'base_path', 
                                                        :resources_path => '/a/path/to/resources')
    data.stubs(:deployers_ssh_keys_dir).returns('deployers_ssh_keys')
    config = DpkgTools::Package::Config.new('name', '1', :base_path => 'base_path')
    DpkgTools::Package::Rails::Setup.expects(:bootstrap_file).with('base_path', 'apache.conf.erb')
    
    DpkgTools::Package::Rails::Setup.expects(:create_dir_if_needed).with('deployers_ssh_keys')
    
    DpkgTools::Package::Rails::Setup.expects(:sh).with('capify "base_path"')
    DpkgTools::Package::Rails::Setup.expects(:generate_mongrel_cluster_config).with(@data, @config)
    
    DpkgTools::Package::Rails::Setup.prepare_package(@data, @config)
  end
  
  it "should be able to back up and reset the resource files created by .prepare_package" do
    DpkgTools::Package::Rails::Setup.stubs(:resource_file_names).returns(['apache.conf.erb'])
    DpkgTools::Package::Rails::Setup.expects(:bootstrap_file).with('base_path', 'apache.conf.erb', :backup => true)
    
    DpkgTools::Package::Rails::Setup.reset_package_resource_files(@data, @config)
  end
  
  it "should be able to generate the complete config/mongrel_cluster.yml hash" do
    DpkgTools::Package::Rails::Setup.generate_mongrel_cluster_config_hash(@data, @config).
      should == {'port' => "8000",
                 'environment' => 'production',
                 'address' => '127.0.0.1',
                 'servers' => 3,
                 'pid_file' => '/var/run/name/mongrel.pid',
                 'cwd' => '/var/lib/name/current',
                 'log_file' => 'log/mongrel.log',
                 'user' => 'name',
                 'group' => 'name'}
  end
  
  it "should be able to write the config/mongrel_cluster.yml file" do
    conf_data = {'port' => '8000'}
    conf_data.expects(:to_yaml).returns("---\nport: blah")
    DpkgTools::Package::Rails::Setup.expects(:generate_mongrel_cluster_config_hash).with(@data, @config).returns(conf_data)
    mock_file = mock('File')
    mock_file.expects(:write).with("# Auto-generated by dpkg-tools, don't edit!\n# You can edit config/deb.yml and then regenerate this file\n# with rake dpkg:mongrel_cluster.\n\nport: blah")
    File.expects(:open).with('base_path/config/mongrel_cluster.yml', 'w').yields(mock_file)
    
    DpkgTools::Package::Rails::Setup.generate_mongrel_cluster_config(@data, @config)
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
  
  it "should properly invoke .prepare_package from #prepare_package" do
    DpkgTools::Package::Rails::Setup.expects(:prepare_package).with(@setup.data, @setup.config)
    @setup.prepare_package
  end
  
  it "should properly invoke .prepare_package from #prepare_package" do
    DpkgTools::Package::Rails::Setup.expects(:generate_mongrel_cluster_config).with(@setup.data, @setup.config)
    @setup.generate_mongrel_cluster_config
  end
  
  it "should properly invoke .reset_package_resource_files from #reset_package_resource_files" do
    DpkgTools::Package::Rails::Setup.expects(:reset_package_resource_files).with(@setup.data, @setup.config)
    @setup.reset_package_resource_files
  end
end