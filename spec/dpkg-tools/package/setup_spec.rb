require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Setup, "#create_structure" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Data", :name => 'hello', :version => '1')
    DpkgTools::Package::Config.expects(:new).with('hello', '1', {}).returns :config
    
    @setup = DpkgTools::Package::Setup.new(@data, :base_path => 'base_path')
  end
  
  it "should be able to provide the options needed for DpkgTools::Package::Config" do
    @setup.config_options.should == {}
  end
  
  it "should be able to perform all the steps needed to create the package structure" do
    DpkgTools::Package.expects(:check_package_dir).with(:config)
    
    @setup.expects(:prepare_package)
    @setup.expects(:write_control_files)
    
    @setup.create_structure
  end
  
  it "should be able to write out the control files" do
    mock_control_file = mock('DpkgTools::Package::ControlFile::* instance')
    mock_control_file.expects(:write)
    
    mock_control_file_class = mock('DpkgTools::Package::ControlFile::* class')
    mock_control_file_class.expects(:new).with(@data, :config).returns(mock_control_file)
    
    @setup.expects(:control_file_classes).returns([mock_control_file_class])
    
    @setup.write_control_files
  end
end