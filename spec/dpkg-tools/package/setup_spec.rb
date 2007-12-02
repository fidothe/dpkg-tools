require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Setup, "bootstrapping" do
  it "should respond to needs_bootstrapping?" do
    DpkgTools::Package::Setup.needs_bootstrapping?('base_path').should be_false
  end
  
  it "should respond to bootstrap" do
    DpkgTools::Package::Setup.should respond_to(:bootstrap)
  end
end

describe DpkgTools::Package::Setup, "#create_structure" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Data", :name => 'hello', :version => '1')
    DpkgTools::Package::Config.root_path = '/a/path/to/package/dirs'
    @config = DpkgTools::Package::Config.new('hello', '1', {})
    DpkgTools::Package::Config.expects(:new).with('hello', '1', {}).returns(@config)
    
    @setup = DpkgTools::Package::Setup.new(@data, :base_path => 'base_path')
  end
  
  it "should be able to provide the options needed for DpkgTools::Package::Config" do
    @setup.config_options.should == {}
  end
  
  it "should be able to perform all the steps needed to create the package structure" do
    DpkgTools::Package.expects(:check_package_dir).with(@config)
    
    @setup.expects(:prepare_package)
    @setup.expects(:write_control_files)
    @setup.expects(:copy_maintainer_script_templates)
    
    @setup.create_structure
  end
  
  it "should be able to write out the control files" do
    mock_control_file = mock('DpkgTools::Package::ControlFile::* instance')
    mock_control_file.expects(:write)
    
    mock_control_file_class = mock('DpkgTools::Package::ControlFile::* class')
    mock_control_file_class.expects(:new).with(@data, @config).returns(mock_control_file)
    
    @setup.expects(:control_file_classes).returns([mock_control_file_class])
    
    @setup.write_control_files
  end
  
  it "should be able to copy across any of the maintainer script templates present in the resources dir" do
    @data.stubs(:resources_path).returns('/a/path/to/resources')
    File.expects(:file?).with('/a/path/to/resources/post-inst.erb').returns(true)
    File.expects(:file?).with('/a/path/to/resources/post-rm.erb').returns(false)
    File.expects(:file?).with('/a/path/to/resources/pre-inst.erb').returns(false)
    File.expects(:file?).with('/a/path/to/resources/pre-rm.erb').returns(true)
    
    FileUtils.expects(:cp).with('/a/path/to/resources/post-inst.erb', '/a/path/to/package/dirs/hello-1/debian/post-inst.erb')
    FileUtils.expects(:cp).with('/a/path/to/resources/pre-rm.erb', '/a/path/to/package/dirs/hello-1/debian/pre-rm.erb')
    
    @setup.copy_maintainer_script_templates
  end
  
  it "should provide a no-op version of prepare_package" do
    @setup.should respond_to(:prepare_package)
  end
end